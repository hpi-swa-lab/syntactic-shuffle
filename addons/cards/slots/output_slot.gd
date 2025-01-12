@tool
extends Slot
class_name OutputSlot

## Provide an output from a card, to be used by an [InputSlot].

@export var connected_input_node_path: NodePath

static func create(num_args: int) -> OutputSlot:
	var o = OutputSlot.new()
	o.num_args = num_args
	return o

func get_connected(node):
	return node.get_node_or_null(connected_input_node_path)
func get_connected_input(node):
	var c = get_connected(node)
	return c.get_input_slot() if c else null
func invoke(card: Card, args: Array = []):
	assert(self.num_args == args.size())
	var i = get_connected_input(card)
	if i:
		i.invoke(args)
		on_activated(card.connection_draw_node)
func can_connect_to(object):
	return object is Card and not object.disable and object.slots.any(func (s):
		return s is InputSlot and self.num_args == s.num_args)
func connect_to(from: Node, object: Node):
	connected_input_node_path = from.get_path_to(object)
func check_disconnect(me: Card, other):
	var o = get_connected(me)
	if o and o.global_position.distance_to(me.global_position) > Card.MAX_CONNECTION_DISTANCE:
		connected_input_node_path = NodePath()
func draw(node, draw_node):
	var to = get_connected(node)
	if to: draw_connection(node, to, false, draw_node)
func get_draw_dependencies(card: Card, deps: Array):
	var object = card.get_node_or_null(connected_input_node_path)
	if object:
		deps.push_back(object.global_position)
		deps.push_back(card.global_position)
