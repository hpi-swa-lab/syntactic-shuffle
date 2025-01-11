@tool
extends Node2D
class_name CardVisual

signal dragging(d: bool)

func setup(name: String, description: String, icon: String, type_icon: String, extra_ui: Control):
	%Name.text = name
	%Description.text = description
	%Icon.path = "res://addons/cards/icons/" + icon
	%TypeIcon.path = "res://addons/cards/icons/" + type_icon
	if extra_ui:
		%MainColumn.add_child(extra_ui)

func icon_from_theme(name: StringName):
	if Engine.is_editor_hint():
		var ref = self if get_viewport().get_parent() == null else get_viewport().get_parent().get_parent()
		return ref.get_theme_icon(name, &"EditorIcons")
	else:
		return null

func _ready() -> void:
	$CardControl.gui_input.connect(input_event)
	$CardControl.focus_mode = Control.FocusMode.FOCUS_ALL

var held = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		held = e.is_pressed()
		dragging.emit(held)
	if e is InputEventMouseMotion and held:
		get_parent().position += e.screen_relative / get_viewport_transform().get_scale()

# if we move from the hand to the main scene, we won't receive the mouse button up
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and held and not e.is_pressed():
		print("HELD GONE")
		held = false
