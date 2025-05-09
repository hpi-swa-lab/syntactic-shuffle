@tool
extends EditorDebuggerPlugin
class_name EditorSync

var editor_interface: EditorInterface

func _init(editor_interface: EditorInterface):
	self.editor_interface = editor_interface

func _has_capture(prefix):
	return prefix == "cards"

func _capture(message, data, session_id):
	var scene = editor_interface.get_edited_scene_root().get_parent()
	match message:
		"cards:save":
			var path = data[0]
			var src = data[1]
			var s = load(path)
			s.source_code = src
			s.reload(true)
			ResourceSaver.save(s, path)
			editor_interface.get_resource_filesystem().update_file(path)
		"cards:spawn":
			var parent_path = data[0]
			var id = data[1]
			var script_path = data[2]
			var index = data[3]
			
			var node = load(script_path).new()
			node.id = id
			# strip the /root/ part
			var parent = scene.get_node_or_null(str(parent_path).substr(6))
			parent.add_child(node, true)
			parent.move_child(node, index)
			node.owner = scene.get_child(0)
		"cards:move_boundary":
			var card = find_node_for_id(data[0], scene)
			var boundary = find_node_for_id(data[1], scene)
			if card and boundary: card.reparent(boundary)
		"cards:delete":
			var obj = find_node_for_id(data[0], scene)
			if obj: obj.queue_free()
		"cards:set_prop":
			var id = data[0]
			var field = data[1]
			var value = data[2]
			var obj = find_node_for_id(id, scene)
			if obj: obj.set(field, value)
	return true

func find_node_for_id(id: String, parent: Node) -> Node:
	for c in parent.get_children():
		if "id" in c and c.id == id:
			return c
		var s = find_node_for_id(id, c)
		if s: return s
	return null
