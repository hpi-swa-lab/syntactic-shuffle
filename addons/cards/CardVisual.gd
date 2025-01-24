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

var expanded = false:
	get: return expanded
	set(v):
		expanded = v
		%Description.visible = not expanded
		%Icon.reparent(%IconMargin if not expanded else %HeaderRow)
		%Icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL if expanded else TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		if expanded: %MainColumn.add_child(card.cards_parent)
		else: %MainColumn.remove_child(card.cards_parent)

@export var paused = false:
	get: return paused
	set(v):
		paused = v
		$CardControl.self_modulate = Color(Color.WHITE, 0.5 if paused else 1.0)

func title(s: String): %Name.text = s
func description(s: String): %Description.text = s
func icon(s: Texture): %Icon.texture = s
func ui(c: Control): %extra_ui.add_child(c)

var card: Card:
	get: return get_parent()

func _ready() -> void:
	$CardControl.gui_input.connect(input_event)
	base_card_size = $CardControl.size

var held = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		held = e.is_pressed()
		dragging.emit(held)
	if e is InputEventMouseMotion and held:
		get_parent().position += e.screen_relative / get_viewport_transform().get_scale()
	if e is InputEventMouseButton and e.double_click:
		expanded = not expanded

# if we move from the hand to the main scene, we won't receive the mouse button up
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion and held:
		input_event(e)
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and held and not e.is_pressed():
		input_event(e)
