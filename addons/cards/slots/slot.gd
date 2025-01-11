@tool
extends Resource
class_name Slot

@export var num_args = 0
var arrows_offset = 0.0

func can_connect_to(object):
	return false
func connect_to(from: Node, object: Node):
	pass
func check_disconnect(card: Card):
	pass
func draw(node, draw_node):
	pass
func get_draw_dependencies(card: Card, array: Array):
	pass
func draw_connection(from, to, inverted, draw_node):
	if not to: return
	var target = to.global_position
	var distance = target.distance_to(from.global_position)
	var angle = from.global_position.angle_to_point(target) - from.get_global_transform().get_rotation()
	draw_node.draw_set_transform(Vector2.ZERO, angle - PI / 2)
	const SIZE = 3
	const GAP = SIZE * 2.2
	
	var offset = arrows_offset * GAP
	offset = offset - int(offset)
	# TODO inverted
	for i in range(0, distance / GAP):
		draw_arrow(draw_node, Vector2(0, (i + offset) * GAP), SIZE)

func draw_arrow(node, pos, size = 10):
	node.draw_polyline(
		[pos + Vector2(-size, 0), pos + Vector2(0, size), pos + Vector2(size, 0)],
		Color(Color.GRAY, 1.0 if true else 0.3),
		size / 2,
		true)

## Create a fixed connection to some object.
class FixedSlot extends Slot:
	var connected_input_node_path: NodePath
	var object_path: NodePath
	func get_connected(node):
		return node.get_node_or_null(connected_input_node_path)
	func get_connected_input(node):
		return get_connected(node).get_input_slot()
	func get_object(card: Card):
		return card.get_node_or_null(connected_input_node_path)
	func can_connect_to(object):
		return object is Card and object.slots.any(func (s):
			return (s is InputSlot or s is OutputSlot) and self.num_args == s.num_args)
	func connect_to(from: Node, object: Node):
		var slot = object.slots.filter(func (s):
			return (s is InputSlot or s is OutputSlot) and self.num_args == s.num_args)[0]
		if slot is InputSlot:
			connected_input_node_path = from.get_path_to(object)
		else:
			var output = object.get_output_slot()
			output.connect_to(object, from)
	func check_disconnect(card: Card):
		var o = get_connected(card)
		if o and o.global_position.distance_to(card.global_position) > Card.MAX_CONNECTION_DISTANCE:
			connected_input_node_path = NodePath()
	func invoke(card: Card, args: Array = []):
		assert(self.num_args == args.size())
		var i = get_connected_input(card)
		var object = card.get_node_or_null(object_path)
		if i and object: i.invoke([object])
	func draw(node, draw_node):
		var object = node.get_node_or_null(object_path)
		if object: draw_connection(node, object, true, draw_node)

class NamedSlot extends Slot:
	func _init(name: String) -> void:
		self.name = name
