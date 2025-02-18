extends Node2D
class_name CardEditor

signal physics_process(delta: float)
signal process(delta: float)
signal after_edit(cards: Array[Card])

var selecting = false
var selection = {}
var open_cards := [] as Array[Card]
var card_library = []

func _process(delta: float) -> void:
	process.emit(delta)

func _physics_process(delta: float) -> void:
	physics_process.emit(delta)

#############
# OPEN CLOSE TOPLEVEL CARDS
#############

func card_content_edited(card: Card):
	after_edit.emit([card])

func card_connected(from: Card, to: Card):
	after_edit.emit([from, to])

func card_disconnected(from: Card, to: Card):
	after_edit.emit([from, to])

func card_template_moved(card: Card, from: String, to: String):
	for info in card_library:
		if info["path"] == from:
			info["path"] = to
			info["name"] = card.card_name

func card_template_created(card: Card):
	card_library.push_back({"name": card.card_name, "path": card.get_script().resource_path})

func card_template_saved(card: Card):
	var index = open_cards.find(card)
	if index >= 0: %ToplevelCardsList.set_tab_title(index, card.card_name)

func card_template_deleted(card: Card):
	var index = open_cards.find(card)
	if index >= 0: %ToplevelCardsList.remove_tab(index)
	
	for info in card_library:
		if info["path"] == card.get_script().resource_path:
			card_library.erase(info)
			break

const SAVE_FILE = "user://state.save"

func _ready() -> void:
	for info in ProjectSettings.get_global_class_list():
		if info["base"] == "Card": card_library.push_back({"name": info["class"], "path": info["path"]})
	%Search.list = card_library
	
	if FileAccess.file_exists(SAVE_FILE):
		var save = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
		if save and save["open_paths"]:
			for p in save["open_paths"]: load_cards(p)

func _exit_tree() -> void:
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	save_file.store_string(JSON.stringify({"open_paths": open_cards.map(func(c): return c.get_script().resource_path)}))

func load_cards(path):
	if FileAccess.file_exists(path):
		var card = load(path).new()
		open_toplevel_card(card)

func save_card():
	%Editor._on_save_button_pressed()

func center_camera():
	var c = %Editor.card.cards
	if c.is_empty():
		%CardEditor.position = Vector2.ZERO
	else:
		%CardEditor.position = c.reduce(func(sum, current): return sum + current.global_position, Vector2.ZERO) / c.size()

func open_toplevel_card(card: Card, open = true):
	%Editor.visible = true
	
	# card itself remains offscreen, but we need to initialize its signatures etc
	card._ready()
	
	open_cards.push_back(card)
	%ToplevelCardsList.add_tab(card.card_name)
	
	if open:
		%ToplevelCardsList.current_tab = open_cards.size() - 1

func _on_toplevel_cards_list_tab_changed(tab: int) -> void:
	if tab < 0: return
	
	if %ToplevelContainer.get_child_count() > 0:
		%ToplevelContainer.remove_child(%ToplevelContainer.get_child(0))
	%ToplevelContainer.add_child(open_cards[tab].cards_parent)
	%Editor.attach_cards(open_cards[tab], Vector2.ZERO, true)
	center_camera()

func _on_toplevel_cards_list_tab_close_pressed(tab: int) -> void:
	open_cards[tab].queue_free()
	open_cards.remove_at(tab)
	%ToplevelCardsList.remove_tab(tab)
	if open_cards.is_empty():
		%Editor.visible = false

func _on_add_button_pressed() -> void:
	open_toplevel_card(BlankCard.new())

#############
# SHORTCUTS
#############

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.key_label == KEY_SPACE and event.ctrl_pressed and event.pressed:
		%Search.start_focus()
		get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selecting = event.is_pressed()
		if selecting:
			clear_selection()
			get_viewport().gui_release_focus()
	if event is InputEventKey and (event.key_label == KEY_DELETE or event.key_label == KEY_BACKSPACE) and event.pressed:
		delete_selected()
	if event is InputEventKey and event.key_label == KEY_D and event.ctrl_pressed and event.pressed:
		duplicate_selected()
	if event is InputEventKey and event.key_label == KEY_G and event.ctrl_pressed and event.pressed:
		group_selected()
	if event is InputEventKey and event.key_label == KEY_S and event.ctrl_pressed and event.pressed:
		save_card()

#############
# SELECTION HANDLING
#############

func clear_selection():
	for card in selection:
		if is_instance_valid(card) and card.visual: card.visual.on_deselected()
	selection.clear()

func get_single_selection():
	var s = get_selection()
	if s.size() == 1: return s[0]
	return null

func get_selection():
	return selection.keys().filter(func(k): return is_instance_valid(k) and k.is_visible_in_tree())

func set_as_selection(obj: Node):
	clear_selection()
	add_to_selection(obj)

func is_selected(obj: Node):
	return selection.has(obj)

func add_to_selection(obj: Node):
	selection[obj] = true
	if obj.visual: obj.visual.on_selected()

func consider_selection(obj: Node):
	if selecting: add_to_selection(obj)

func move_selected(delta: Vector2):
	for card in selection: card.position += delta

func delete_selected():
	for card in selection:
		if is_instance_valid(card): card.queue_free()
	selection.clear()

func duplicate_selected():
	var src = Card.serialize_card_construction(selection.keys())
	
	var container = G.eval_object("@tool\nextends Card\nfunc s():\n{0}".format([src]), func(): return Card.new())
	
	var parent = selection.keys()[0].get_parent()
	clear_selection()
	for c in container.cards:
		container.cards_parent.remove_child(c)
		parent.add_child(c)
		add_to_selection(c)

func group_selected():
	var cards = selection.keys()
	clear_selection()
	var parent = BlankCard.new()
	cards[0].get_parent().add_child(parent)
	parent.position = cards.map(func(c): return c.position).reduce(func(sum, v): return sum + v) / cards.size() - CardVisual.DEFAULT_EDITOR_SIZE * parent.get_base_scale() * 0.25
	if parent.visual: parent.visual.expanded = true
	
	var before = []
	var after = []
	var incoming = []
	var outgoing = []
	var add_input = func(from, to, named, export_name):
		var sig = from.output_signatures
		# FIXME choosing first
		var input = NamedInCard.named_data(named, sig[0]) if export_name else InCard.data(sig[0])
		parent.add_card(input)
		before.push_back(func():
			to.disconnect_from(from))
		after.push_back(func():
			from.connect_to(parent, named if export_name else "")
			input.connect_to(to, named))
	var add_output = func(from, to, named, output):
		if not output.get_parent(): parent.add_card(output)
		before.push_back(func():
			from.disconnect_from(to))
		after.push_back(func():
			parent.connect_to(to, named)
			from.c(output))
	
	for c in cards:
		for i in c.get_incoming(): if not cards.has(i): incoming.push_back([i, c, "", false])
		for i in c.get_outgoing(): if not cards.has(i): outgoing.push_back([c, i, "", OutCard.new()])
		for n in c.named_incoming:
			for p in c.named_incoming[n]:
				var i = c.get_node(p)
				if not cards.has(i): incoming.push_back([i, c, n, false])
		for n in c.named_outgoing:
			for p in c.named_outgoing[n]:
				var i = c.get_node(p)
				if not cards.has(i): outgoing.push_back([c, i, n, OutCard.new()])
	for c in cards: CardBoundary.card_moved(c, parent.cards_parent)
	
	# Check for outputs that have an identical signature and merge them
	for i in range(0, outgoing.size()):
		for j in range(i + 1, outgoing.size()):
			if outgoing[i][0].has_same_out_signatures(outgoing[j][0]):
				outgoing[j][3].free()
				outgoing[j][3] = outgoing[i][3]
				break
	
	# Check for unnamed inputs that have identical signature and give then names
	var groups = {}
	for i in incoming:
		if i[2]: continue
		# FIXME using only first one
		var sig = i[0].output_signatures[0]
		var found = false
		for g in groups:
			if sig.eq(g):
				groups[g].push_back(i)
				found = true
				break
		if not found:
			groups[sig] = [i]
	# if there are groups of identical inputs, add names
	for sig in groups:
		var list = groups[sig]
		if list.size() > 1:
			for i in range(0, list.size()):
				list[i][2] = sig.get_description() + "_" + str(i)
				list[i][3] = true
	
	for i in range(0, incoming.size()):
		if incoming[i][2]: continue
		for j in range(i + 1, incoming.size()):
			if incoming[j][2]: continue
			if incoming[i][0].has_same_out_signatures(incoming[j][0]):
				pass
	
	for t in before: t.call()
	for pair in incoming: add_input.call(pair[0], pair[1], pair[2], pair[3])
	for pair in outgoing: add_output.call(pair[0], pair[1], pair[2], pair[3])
	for t in after: t.call()
	var i_y = 0
	var o_y = 0
	for i in parent.cards:
		if i is InCard:
			i.position = Vector2(100, 400 * i_y + 400)
			i_y += 1
		if i is OutCard:
			i.position = Vector2(CardVisual.DEFAULT_EDITOR_SIZE.x - 100, 400 * o_y + 400)
			o_y += 1
	
	return parent

func spawn_connected(script_path: String, open_toplevel = false):
	var script = load(script_path)
	var create = script.get_script_method_list().filter(func(m): return m["name"] == "create_default")
	var card = script.create_default() if create else script.new()
	
	if open_toplevel:
		open_toplevel_card(card)
		return
	
	var selected: Card = get_single_selection()
	var parent
	var pos
	if selected:
		parent = selected.parent
		if not parent: parent = selected.get_parent()
		pos = selected.position + Vector2(400 * selected.scale.x, 0)
	else:
		var camera_pos = get_viewport_rect().size / 2
		var b = CardBoundary.boundary_at_position(camera_pos)
		pos = Vector2(300, 300)
		parent = b.get_parent_card()
		if not parent: parent = b
	
	card.position = pos
	
	parent.add_card(card)
	if selected: selected.try_connect(card)
	set_as_selection(card)
	card.visual.try_focus()

func _on_search_item_selected(item, shift: Variant) -> void:
	spawn_connected(item["path"], shift)
