@tool
extends Node2D
class_name CardVisual

enum Type {
	Trigger,
	Effect,
	Store
}

static var base_card_size = Vector2(10, 10)

signal dragging(d: bool)

@export var paused = false:
	get: return paused
	set(v):
		paused = v
		$CardControl.self_modulate = Color(Color.WHITE, 0.5 if paused else 1.0)

func title(s: String): %Name.text = s
func description(s: String): %Description.text = s
func icon(s: Texture): %Icon.texture = s
func ui(c: Control): %extra_ui.add_child(c)

func _ready() -> void:
	$CardControl.gui_input.connect(input_event)
	base_card_size = $CardControl.size

func _process(delta: float):
	if held and not get_parent().can_drag():
		held = false
		dragging.emit(held)

var held = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and get_parent().can_drag():
		held = e.is_pressed()
		dragging.emit(held)
	if e is InputEventMouseMotion and held:
		get_parent().position += e.screen_relative / get_viewport_transform().get_scale()

# if we move from the hand to the main scene, we won't receive the mouse button up
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion and held:
		input_event(e)
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and held and not e.is_pressed():
		input_event(e)
