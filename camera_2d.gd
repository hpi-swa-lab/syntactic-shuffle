extends Camera2D
class_name CardEditor

signal physics_process(delta: float)
signal process(delta: float)

@export var zoom_speed = 0.1
@export var pan = true

var held = false
var selecting = false
var selection = {}

func _ready():
	Card.set_ignore_object(self)
	
	await get_tree().process_frame
	load_cards()

func _zoom(factor: float) -> void:
	var delta = get_global_mouse_position() - global_position
	delta = delta - delta * zoom.x / (zoom.x + factor)
	zoom += Vector2(factor, factor)
	position += delta

func _process(delta: float) -> void:
	process.emit(delta)

func _physics_process(delta: float) -> void:
	physics_process.emit(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and pan:
		held = event.is_pressed()
	if event is InputEventMouseMotion and held:
		position -= event.screen_relative / zoom
	if event is InputEventKey and event.key_label == KEY_SPACE and event.ctrl_pressed and event.pressed:
		G.at("search").start_focus()
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
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
		save_cards()
	if event is InputEventPanGesture:
		_zoom(-1 * event.delta.y * zoom.x)
	if event is InputEventMouseButton:
		var factor = 0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: factor = -1
			MOUSE_BUTTON_WHEEL_UP: factor = 1
			_: factor = 0
		if factor != 0: _zoom(factor * event.factor * zoom_speed * zoom.x)

func clear_selection():
	for card in selection:
		if is_instance_valid(card) and card.visual: card.visual.on_deselected()
	selection.clear()

func get_single_selection():
	var s = get_selection()
	if s.size() == 1: return s[0]
	return null

func get_selection():
	return selection.keys().filter(func(k): return is_instance_valid(k))

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

func spawn_connected(script_path):
	var camera_pos = get_screen_center_position()
	var selected: Card = get_single_selection()
	var parent
	var pos
	if selected:
		parent = selected.parent
		if not parent: parent = selected.get_parent()
		pos = selected.position + Vector2(400 * selected.scale.x, 0)
	else:
		# FIXME doesn't quite work yet
		var b = CardBoundary.boundary_at_position(camera_pos)
		pos = camera_pos * b.global_transform.inverse()
		parent = b.get_parent_card()
		if not parent: parent = b
	
	var script = load(script_path)
	var create = script.get_script_method_list().filter(func (m): return m["name"] == "create_default")
	var card = script.create_default() if create else script.new()
	card.position = pos
	
	parent.add_card(card)
	if selected: selected.try_connect(card)
	set_as_selection(card)
	card.visual.try_focus()

const PROGRAM_FILE = "res://program.gd"

func save_cards(path = PROGRAM_FILE):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string("@tool\nextends Card\nfunc s():\n" + Card.serialize_card_construction(get_parent().get_cards()))

func load_cards(path = PROGRAM_FILE):
	if FileAccess.file_exists(path):
		var container = load(path).new()
		var parent = get_parent()
		# make sure _ready is called only once all cards are in place
		_unmount_while(parent, func ():
			for card in container.cards: card.reparent(parent, false))

func _unmount_while(node: Node, cb: Callable):
	var index = node.get_index()
	var parent = node.get_parent()
	parent.remove_child(node)
	cb.call()
	parent.add_child(node)
	parent.move_child(node, index)
