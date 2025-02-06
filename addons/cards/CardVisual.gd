@tool
extends Node2D
class_name CardVisual

enum Type {
	Trigger,
	Effect,
	Store
}

const DEFAULT_EDITOR_SIZE = Vector2(2000, 1600)
static var base_card_size = Vector2(10, 10)
var editor = null
var _container_size = DEFAULT_EDITOR_SIZE

signal dragging(d: bool)

var expanded = false:
	get: return expanded
	set(v):
		expanded = v
		
		%CardControl.visible = not expanded
		
		if expanded:
			editor = load("res://addons/cards/code_editor.tscn" if card is CodeCard else "res://addons/cards/card_editor.tscn").instantiate()
			editor.position = %CardControl.get_rect().size / -2
			editor.gui_input.connect(input_event)
			add_child(editor)
			await editor.attach_cards(card, _container_size)
			card.cards_parent.fill_rect(editor.get_rect())
		elif editor:
			editor.detach_cards()
			editor.queue_free()

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
func container_size(size: Vector2): _container_size = size

var card: Card:
	get: return get_parent()

func _ready() -> void:
	%CardControl.gui_input.connect(input_event)
	base_card_size = %CardControl.size

func get_rect():
	return global_transform * %CardControl.get_rect()

var held = false
var is_dragging = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.is_pressed():
		held = true
		if not get_selection_manager().is_selected(card):
			get_selection_manager().set_as_selection(card)
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.is_pressed():
		held = false
		is_dragging = false
		dragging.emit(false)
	if e is InputEventMouseMotion and held:
		if not is_dragging:
			is_dragging = true
			dragging.emit(true)
		get_selection_manager().move_selected(e.screen_relative / get_viewport_transform().get_scale() / card.get_card_boundary().global_scale)
	if e is InputEventMouseButton and e.double_click and e.button_index == MOUSE_BUTTON_LEFT:
		held = false
		is_dragging = false
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
	for signature in card.input_signatures:
		var s = signature.get_description()
		inputs.push_back(s)
		# inputs.push_back(c.input_name + ": " + s if c is NamedInCard else s)
	var remembered = ""
	for c in card.cards:
		if c is OutCard:
			var r = c.get_remembered_value()
			if r: remembered += "\nR: " + str(r)
	
	%signatures.visible = true
	%inputs.text = "\n".join(inputs)
	%outputs.text = "\n".join(card.output_signatures.map(func(s): return s.get_description())) + remembered
	
	get_selection_manager().consider_selection(card)

func _on_card_control_mouse_exited() -> void: %signatures.visible = false

func get_selection_manager() -> CardCamera:
	return get_viewport().get_camera_2d()
