@tool
extends EditorPlugin
class_name CardsAddon

var cards = {}
var selected_card: Card = null

func _enter_tree() -> void:
	G.put("addon", self)
	var base = get_editor_interface().get_base_control()
	find_behavior_classes(func(name, script, icon):
		add_custom_type(name, "Node2D", script, base.get_theme_icon(icon, &"EditorIcons"))
		cards[name] = icon)

## List all behaviors in their folder and install as custom types
static func find_behavior_classes(callback: Callable):
	var regex = RegEx.new()
	regex.compile("#thumb\\(\"(.+)\"\\)")
	for file in DirAccess.get_files_at("res://addons/cards/cards"):
		var name = file.get_basename()
		var icon = ""
		var script = load("res://addons/cards/cards/" + file)
		var result = regex.search(script.source_code)
		if result:
			icon = result.strings[1]
		else:
			push_error("Card {0} is missing #thumb(\"...\") annotation".format([name]))
		callback.call(name, script, icon)

func _forward_canvas_gui_input(event):
	if not selected_card: return false
	var ret = selected_card._forward_canvas_gui_input(event, get_undo_redo())
	if ret: update_overlays()
	return ret

func _exit_tree():
	for key in cards:
		remove_custom_type(key)
	cards.clear()

func _handles(object: Object) -> bool:
	return true

func _edit(object: Object) -> void:
	if selected_card:
		selected_card.set_selected(false)
		selected_card = null
	if object is Card:
		selected_card = object
		object.set_selected(true)
