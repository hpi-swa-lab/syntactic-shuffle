extends Resource
class_name Slot

var num_args = 0
var arrows_offset = 0.0
func can_connect_to(object):
	return false
func connect_to(from: Node, object: Node):
	pass
func check_disconnect(card: Card):
	pass
func draw(node):
	pass
func get_draw_dependencies(card: Card, array: Array):
	pass
func draw_connection(from, to, inverted = false):
	if not to: return
	var target = to.global_position
	var distance = target.distance_to(from.global_position)
	var angle = from.global_position.angle_to_point(target) - from.get_global_transform().get_rotation()
	from.draw_set_transform(Vector2.ZERO, angle - PI / 2)
	const SIZE = 3
	const GAP = SIZE * 2.2
	
	var offset = arrows_offset * GAP
	offset = offset - int(offset)
	# TODO inverted
	
	for i in range(0, distance / GAP):
		draw_arrow(from, Vector2(0, (i + offset) * GAP), SIZE)

func draw_arrow(node, pos, size = 10):
	node.draw_polyline(
		[pos + Vector2(-size, 0), pos + Vector2(0, size), pos + Vector2(size, 0)],
		Color(Color.GRAY, 1.0 if true else 0.3),
		size / 2,
		true)

## Provide an object as input, for example Collision triggers need to know
## which object to listen to collisions for.
class ObjectInputSlot extends Slot:
	var on_connect
	var on_disconnect
	@export var object_path: NodePath
	func _init(on_connect = null, on_disconnect = null) -> void:
		self.on_connect = on_connect
		self.on_disconnect = on_disconnect
	func get_object(card: Card):
		return card.get_node_or_null(object_path)
	func can_connect_to(object):
		return not object is Card and object.get_parent() and object.get_parent().name == "main" and not object is Camera2D
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

## Provide an input from another card's output.
class InputSlot extends Slot:
	var _invoke: Callable
	func _init(invoke: Callable) -> void:
		self._invoke = invoke
		self.num_args = invoke.get_argument_count()
	func can_connect_to(object):
		return object is Card and object.slots.any(func (s):
			return s is OutputSlot and self.num_args == s.num_args)
	func connect_to(from: Node, object: Node):
		var output = object.get_output_slot()
		output.connect_to(object, from)
	func invoke(args):
		self._invoke.callv(args)

## Provide an output from a card, to be used by an [InputSlot].
class OutputSlot extends Slot:
	var connected_input_node_path: NodePath
	func _init(num_args: int) -> void:
		self.num_args = num_args
	func get_connected(node):
		return node.get_node_or_null(connected_input_node_path)
	func get_connected_input(node):
		var c = get_connected(node)
		return c.get_input_slot() if c else null
	func invoke(card: Card, args: Array = []):
		assert(self.num_args == args.size())
		var i = get_connected_input(card)
		if i: i.invoke(args)
	func can_connect_to(object):
		return object is Card and object.slots.any(func (s):
			return s is InputSlot and self.num_args == s.num_args)
	func connect_to(from: Node, object: Node):
		connected_input_node_path = from.get_path_to(object)
	func check_disconnect(card: Card):
		var o = get_connected(card)
		if o and o.global_position.distance_to(card.global_position) > Card.MAX_CONNECTION_DISTANCE:
			connected_input_node_path = NodePath()
	func draw(node):
		var to = get_connected(node)
		if to: draw_connection(node, to)
	func get_draw_dependencies(card: Card, deps: Array):
		var object = card.get_node_or_null(connected_input_node_path)
		if object: deps.push_back(object.global_position)

## Output an object from your card, for example a CollisionInfo.
class ObjectOutputSlot extends OutputSlot:
	func _init() -> void:
		super._init(1)

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
	func draw(node):
		var object = node.get_node_or_null(object_path)
		if object: draw_connection(node, object, true)

class NamedSlot extends Slot:
	func _init(name: String) -> void:
		self.name = name
