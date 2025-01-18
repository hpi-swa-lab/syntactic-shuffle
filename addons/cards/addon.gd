@tool
extends EditorPlugin
class_name CardsAddon

var cards = {}
var selected_node: Node2D = null
var debugger: EditorSync

func _enter_tree() -> void:
	add_autoload_singleton("uuid", 'res://addons/cards/uuid.gd')
	add_autoload_singleton("G", 'res://addons/cards/G.gd')
	
	var base = get_editor_interface().get_base_control()
	find_behavior_classes(func(name, script, icon):
		#add_custom_type(name, "Node2D", script, base.get_theme_icon(icon, &"EditorIcons"))
		cards[name] = icon)
	
	debugger = EditorSync.new(get_editor_interface())
	add_debugger_plugin(debugger)

## List all behaviors in their folder and install as custom types
static func find_behavior_classes(callback: Callable):
	var regex = RegEx.new()
	regex.compile("#thumb\\(\"(.o+)\"\\)")
	for file in DirAccess.get_files_at("res://addons/cards/cards"):
		if file.get_extension() != "gd": continue
		var name = file.get_basename()
		var script = load("res://addons/cards/cards/" + file)
		var result = regex.search(script.source_code)
		callback.call(name, script, "")

func _forward_canvas_gui_input(event):
	if not selected_node: return false
	var ret = selected_node._forward_canvas_gui_input(event, get_undo_redo())
	if ret: update_overlays()
	return ret

func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if selected_node is Placeholder:
		selected_node._forward_canvas_draw_over_viewport(viewport_control)

func _exit_tree():
	for key in cards:
		remove_custom_type(key)
	cards.clear()
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("uuid")
	remove_autoload_singleton("G")

func _handles(object: Object) -> bool:
	return true

func _edit(object: Object) -> void:
	if selected_node:
		if selected_node is Card: selected_node.dragging = false
		selected_node = null
	if object is Card or object is Placeholder:
		selected_node = object
		if selected_node is Card: selected_node.dragging = true
