@tool
extends Slot
class_name ObjectInputSlot

## Provide an object as input, for example Collision triggers need to know
## which object to listen to collisions for.

static func create(limit_to_group = "") -> ObjectInputSlot:
	var o = ObjectInputSlot.new()
	o.limit_to_group = limit_to_group
	return o

var on_connect
var on_disconnect
@export var object_path: NodePath
@export var limit_to_group: String = ""

func _init(on_connect = null, on_disconnect = null) -> void:
	self.on_connect = on_connect
	self.on_disconnect = on_disconnect
func get_object(card: Card):
	return card.get_node_or_null(object_path)
func can_connect_to(object: Node):
	return (not object is Card
		and object.get_parent()
		and object.get_parent().name == "main"
		and not object is Camera2D
		and (limit_to_group == "" or object.is_in_group(limit_to_group)))
func connect_to(from: Node, object: Node):
	object_path = from.get_path_to(object)
func check_disconnect(card: Card):
	var o = get_object(card)
	if o and o.global_position.distance_to(card.global_position) > Card.MAX_CONNECTION_DISTANCE:
		object_path = NodePath()
func draw(node):
	var object = node.get_node_or_null(object_path)
	if object: draw_connection(node, object, true)
func get_draw_dependencies(card: Card, deps: Array):
	var object = card.get_node_or_null(object_path)
	if object: deps.push_back(object.global_position)
