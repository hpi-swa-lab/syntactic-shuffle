@tool
extends Node2D
class_name CardVisual

enum Type {
	Trigger,
	Effect,
	Store
}

static var base_card_size = Vector2(10, 10)
var _editor = null

signal dragging(d: bool)

var expanded = false:
	get: return expanded
	set(v):
		expanded = v
		
		%CardControl.visible = not expanded
		
		if expanded:
			_editor = load("res://addons/cards/code_editor.tscn" if card is CodeCard else "res://addons/cards/card_editor.tscn").instantiate()
			_editor.position = %CardControl.get_rect().size / -2
			_editor.gui_input.connect(input_event)
			add_child(_editor)
			_editor.attach_cards(card)
			card.cards_parent.fill_rect(_editor.get_rect())
		elif _editor:
			_editor.detach_cards()
			_editor.queue_free()

@export var paused = false:
	get: return paused
	set(v):
		paused = v
		$CardControl.self_modulate = Color(Color.WHITE, 0.5 if paused else 1.0)

func title(s: String): %Name.text = s
func get_title(): return %Name.text
func description(s: String): %Description.text = s
func get_description(): return %Description.text
func icon(s: Texture): %Icon.texture = s
func icon_data(t: String):
	var image = Image.new()
	image.load_png_from_buffer(Marshalls.base64_to_raw(t))
	icon(ImageTexture.create_from_image(image))
func get_icon_data(): return Marshalls.raw_to_base64(%Icon.texture.get_image().save_png_to_buffer())
func get_icon_path(): return %Icon.texture.resource_path
func get_icon_texture(): return %Icon.texture
func set_icon_texture(texture: Texture): %Icon.texture = texture
func ui(c: Control): %extra_ui.add_child(c)
func short_description(): %Description.max_lines_visible = 2

var card: Card:
	get: return get_parent()

func _ready() -> void:
	%CardControl.gui_input.connect(input_event)
	base_card_size = %CardControl.size

var held = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		held = e.is_pressed()
		if not get_selection_manager().is_selected(card):
			get_selection_manager().set_as_selection(card)
		dragging.emit(held)
	if e is InputEventMouseMotion and held:
		get_selection_manager().move_selected(e.screen_relative / get_viewport_transform().get_scale() / card.get_card_boundary().global_scale)
	if e is InputEventMouseButton and e.double_click and e.button_index == MOUSE_BUTTON_LEFT:
		held = false
		dragging.emit(held)
		expanded = not expanded
		get_selection_manager().clear_selection()

# if we move from the hand to the main scene, we won't receive the mouse button up
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion and held:
		input_event(e)
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and held and not e.is_pressed():
		input_event(e)

func on_selected():
	%CardControl.add_theme_stylebox_override("panel", preload("res://addons/cards/card_selected.tres"))

func on_deselected():
	%CardControl.add_theme_stylebox_override("panel", preload("res://addons/cards/card_normal.tres"))

func _on_card_control_mouse_entered() -> void:
	var inputs = []
	for c in card.cards:
		if c is InCard:
			var s = c.get_concrete_signature().get_description()
			inputs.push_back(c.input_name + ": " + s if c is NamedInCard else s)
	var outputs = [] as Array[Signature]
	card.get_out_signatures(outputs)
	
	%signatures.visible = true
	%inputs.text = "\n".join(inputs)
	%outputs.text = "\n".join(outputs.map(func(s): return s.get_description()))
	
	get_selection_manager().consider_selection(card)

func _on_card_control_mouse_exited() -> void: %signatures.visible = false

func get_selection_manager():
	return get_viewport().get_camera_2d()
