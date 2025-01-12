@tool
extends Slot
class_name InputSlot
## Provide an input from another card's output.

@export var connected_output_node_path: NodePath

signal invoke_called(args: Array)

static func create(num_args: int) -> InputSlot:
	var i = InputSlot.new()
	i.num_args = num_args
	return i

func get_connected(node):
	return node.get_node_or_null(connected_output_node_path)

func get_connected_output(node):
	var c = get_connected(node)
	return c.get_output_slot() if c else null

func invoke(card: Card, args: Array = []):
	invoke_called.emit(args)
	on_activated(card.connection_draw_node)

func can_connect_to(object):
	return object is Card and not object.disable and object.slots.any(func (s):
		return s is OutputSlot and self.num_args == s.num_args)

func connect_to(from: Node, object: Node):
	connected_output_node_path = from.get_path_to(object)
	object.get_output_slot().connected_inputs.push_back([from, self])

func check_disconnect(me: Card, other):
	var o = get_connected(me)
	if not o: return
	var output = o.get_output_slot()
	output.connected_inputs = output.connected_inputs.filter(func(s): return s[1] != self)
	if o and o.global_position.distance_to(me.global_position) > Card.MAX_CONNECTION_DISTANCE:
		connected_output_node_path = NodePath()

func draw(node, draw_node):
	var to = get_connected(node)
	if to: draw_connection(node, to, true, draw_node)

func get_draw_dependencies(card: Card, deps: Array):
	var object = card.get_node_or_null(connected_output_node_path)
	if object:
		deps.push_back(object.global_position)
		deps.push_back(card.global_position)

func ready(card: Card):
	var c = get_connected(card)
	if c: c.get_output_slot().connected_inputs.push_back([card, self])
