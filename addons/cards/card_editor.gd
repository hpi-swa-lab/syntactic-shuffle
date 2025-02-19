extends Panel

var card: Card
var is_fullscreen = false
var unsaved_changes = false:
	get: return unsaved_changes
	set(v):
		unsaved_changes = v
		update_button_state()

func get_editor() -> CardEditor:
	return get_node("/root/main")

func _ready() -> void:
	get_editor().after_edit.connect(func (cards: Array):
		if cards.any(func (c): return card.cards.has(c)): unsaved_changes = true)

func attach_cards(card: Card, size: Vector2, is_fullscreen = false):
	self.card = card
	
	if not is_fullscreen:
		%Column.add_child(card.cards_parent)
	else:
		# cards_parent is mounted in a separate container
		make_fullscreen()
	
	%Name.text = card.visual.get_title()
	update_button_state()
	%Icon.texture_normal = card.visual.get_icon_texture()
	
	if card.cards_parent.get_children().filter(func(c):
		return c is Card and c.position != Vector2.ZERO).is_empty():
		_on_auto_layout_pressed()
	
	await get_tree().process_frame
	
	if not is_fullscreen: self.size = size
	else:
		self.size = get_child(0).get_combined_minimum_size()
		position = Vector2(get_viewport_rect().size.x - self.size.x, 0)
		set_anchors_preset(Control.PRESET_TOP_RIGHT)

func detach_cards():
	if not is_fullscreen: %Column.remove_child(card.cards_parent)

func set_card_script(card: Card, path: String):
	var props = {}
	for p in card.get_script().get_script_property_list(): props[p["name"]] = card.get(p["name"])
	
	card.set_script(load(path))
	for p in props: card.set(p, props[p])

func _on_save_button_pressed(copy = false) -> void:
	var s = card.visual.get_container_size() if is_fullscreen else size
	card.title(%Name.text)
	card.container_size(s)
	
	var new_card = card is BlankCard
	
	var n = %Name.text.to_camel_case().capitalize() + "Card"
	var regex = RegEx.new()
	regex.compile(r"[^A-Za-z0-9]")
	n = regex.sub(n, "", true)
	var path = "res://addons/cards/cards/{0}.gd".format([n])
	var src = card.serialize_gdscript(n, s)
	
	var old_path = null if new_card or copy else card.get_script().resource_path
	if old_path and path != old_path:
		DirAccess.rename_absolute(old_path, path)
		card.get_script().take_over_path(old_path)
		card.get_script().resource_path = path
		get_editor().card_template_moved(card, old_path, path)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(src)
	file.close()
	card.card_name = n
	set_card_script(card, path)
	
	if new_card: get_editor().card_template_created(card)
	get_editor().card_template_saved(card)
	
	unsaved_changes = false
	update_button_state()

func _on_save_copy_button_pressed() -> void:
	_on_save_button_pressed(true)

func _on_auto_layout_pressed() -> void:
	layout_cards(card.cards_parent.get_children().filter(func(c): return c is Card))

func init_positions(cards: Array):
	const RADIUS = 200.0
	const CENTER = Vector2(800, 600)
	var angle_step = 2.0 * PI / cards.size()
	
	var inputs = cards.filter(func(c): return c.get_all_incoming().is_empty())
	for i in range(inputs.size()):
		inputs[i].position = Vector2(200, 400 + i * 400)
	
	var other = cards.filter(func(c): return not (inputs.has(c)))
	for i in range(other.size()):
		var angle = i * angle_step
		other[i].position = CENTER + Vector2(RADIUS * cos(angle), RADIUS * sin(angle))

func layout_cards(cards):
	const MAX_DISTANCE = 200.0
	const REPULSION_FORCE = 300000.0
	const ATTRACTION_FORCE = 1.0
	const ITERATIONS = 5000
	
	init_positions(cards)
	
	for _i in range(ITERATIONS):
		var forces = {}
		for card in cards: forces[card] = Vector2(0, 0)
		
		# repulsion
		for i in range(cards.size()):
			for j in range(i + 1, cards.size()):
				var card_a = cards[i]
				var card_b = cards[j]
				var delta = card_a.position - card_b.position
				var dist = delta.length()
				if dist > 0:
					var repulsion = dist * dist
					repulsion = REPULSION_FORCE / repulsion
					repulsion *= delta.normalized()
					forces[card_a] += repulsion
					forces[card_b] -= repulsion
		
		# attraction
		for card in cards:
			for target in card.get_all_outgoing():
				var delta = target.position - card.position
				var dist = delta.length()
				if dist > 0:
					# pull strongly to inputs
					var factor = 3 if card.get_all_incoming().is_empty() else 1
					var attraction = ATTRACTION_FORCE * factor * delta.normalized()
					# prefer straight lines
					attraction.y *= 2
					forces[card] += attraction
					forces[target] -= attraction
		
		if _i % 1000 == 0: await get_tree().process_frame
		
		for card in cards:
			if not card.get_all_incoming().is_empty(): card.position += forces[card] * 5

func _on_icon_pressed() -> void:
	var editor = preload("res://addons/cards/icon_editor.tscn").instantiate()
	get_parent().add_child(editor)
	editor.global_position = %Icon.global_position - Vector2(editor.get_rect().size.x / 2, 0)
	
	editor.texture = ImageTexture.create_from_image(%Icon.texture_normal.get_image())
	
	editor.save.connect(func(texture):
		%Icon.texture_normal = texture
		card.visual.set_icon_texture(texture))

func _on_name_text_changed(new_text: String) -> void:
	update_button_state()

func update_button_state():
	var new_text = %Name.text
	var new_card = card is BlankCard
	var renamed = not new_card and new_text != card.visual.get_title()
	%SaveCopyButton.visible = renamed
	if new_card: %SaveButton.text = "Create Card"
	elif renamed: %SaveButton.text = "Rename & Save"
	else: %SaveButton.text = "Save Changes"
	%SaveButton.disabled = new_text.is_empty()
	
	if unsaved_changes: %SaveButton.text += " *"

func _on_delete_pressed() -> void:
	DirAccess.remove_absolute(card.get_script().resource_path)
	get_editor().card_template_deleted(card)

var resizing = false
func _on_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		resizing = event.is_pressed()
	if event is InputEventMouseMotion and resizing:
		size += event.relative
		card.cards_parent.fill_rect(get_rect())

func make_fullscreen():
	is_fullscreen = true
	
	%Resize.visible = false
	%MarginContainer.remove_theme_constant_override("margin_bottom")
	%MarginContainer.remove_theme_constant_override("margin_right")
	%MarginContainer.remove_theme_constant_override("margin_top")
	%MarginContainer.remove_theme_constant_override("margin_left")
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	scale = Vector2(0.8, 0.8)
