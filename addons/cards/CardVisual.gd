@tool
extends Node2D
class_name CardVisual

signal dragging(d: bool)

func setup(name: String, description: String, icon: String, type_icon: String):
	%Name.text = name
	%Description.text = description
	%Icon.path = "res://addons/cards/icons/" + icon + ".svg"
	%TypeIcon.path = "res://addons/cards/icons/" + type_icon + ".svg"

func icon_from_theme(name: StringName):
	if Engine.is_editor_hint():
		var ref = self if get_viewport().get_parent() == null else get_viewport().get_parent().get_parent()
		return ref.get_theme_icon(name, &"EditorIcons")
	else:
		return null

func _ready() -> void:
	$CardControl.gui_input.connect(input_event)

var held = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		held = e.is_pressed()
		dragging.emit(held)
	if e is InputEventMouseMotion and held:
		get_parent().position += e.screen_relative / get_viewport_transform().get_scale()
