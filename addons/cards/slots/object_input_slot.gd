@tool
extends Slot
class_name ObjectInputSlot

@export var object_path: NodePath
@export var limit_to_group: String

## Provide an object as input, for example Collision triggers need to know
## which object to listen to collisions for.

static func create(limit_to_group) -> ObjectInputSlot:
	var o = ObjectInputSlot.new()
	o.limit_to_group = limit_to_group
	return o

var on_connect
var on_disconnect

func _init(on_connect = null, on_disconnect = null) -> void:
	self.on_connect = on_connect
	self.on_disconnect = on_disconnect
func get_object(card: Card):
	var o = card.get_node_or_null(object_path)
	if o is CardProxy:
		return o.proxy_target
	else:
		return o
func can_connect_to(object: Node):
	return object.is_in_group(limit_to_group)
func _disconnect(me: Card):
	var object = get_object(me)
	if object and on_disconnect:
		on_disconnect.call(object)
func connect_to(from: Node, object: Node):
	_disconnect(from)
	object_path = from.get_path_to(object)
	if on_connect:
		on_connect.call(get_object(from))
func check_disconnect(me: Card, card: Card):
	var o = get_object(me)
	if o and o.global_position.distance_to(card.global_position) > Card.MAX_CONNECTION_DISTANCE:
		_disconnect(me)
		object_path = NodePath()
func draw(node, draw_node):
	var object = node.get_node_or_null(object_path)
	if object: draw_connection(node, object, true, draw_node)
func get_draw_dependencies(card: Card, deps: Array):
	var object = card.get_node_or_null(object_path)
	if object:
		deps.push_back(object.global_position)
		deps.push_back(card.global_position)
