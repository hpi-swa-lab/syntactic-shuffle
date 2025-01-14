@tool
extends Slot
class_name ObjectInputSlot

## Provide an object as input, for example Collision triggers need to know
## which object to listen to collisions for.

var limit_to_group: String
var _on_connect
var _on_disconnect

func get_slot_name():
	return "__object"

func _init(limit_to_group = "", on_connect = null, on_disconnect = null):
	self.limit_to_group = limit_to_group
	self._on_connect = on_connect
	self._on_disconnect = on_disconnect

func get_object():
	# FIXME single vs multiple
	for info in card.connections[get_slot_name()]:
		var path = info[0]
		var o = card.get_node_or_null(path)
		if o is CardProxy:
			return o.proxy_target
		else:
			return o
	return null

func can_connect_to(object: Node, slot: Slot):
	if not (slot is ObjectOutputSlot
		and (limit_to_group == "" or object.is_in_group(limit_to_group))
		and not object is Camera2D
		and object.get_parent() == card.get_parent()):
			return false
	if has_closer_connection_than(object):
		return false
	return true

func on_connect(object: Node, slot: Slot):
	if _on_connect: _on_connect.call(object)
	delete_all_connections_but(object)

func on_disconnect(object: Node, slot: Slot):
	if _on_disconnect: _on_disconnect.call(object)

func draw(draw_node):
	draw_connections(draw_node, false)

func get_draw_dependencies(deps: Array):
	var connections = card.connections[get_slot_name()]
	deps.push_back(card.global_position)
	for info in connections:
		var to = card.get_node_or_null(info[0])
		if to: deps.push_back(to.global_position)
