@tool
extends Slot
class_name OutputSlot

## Provide an output from a card, to be used by an [InputSlot].

@export var connected_input_node_path: NodePath

var connected_inputs = []

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
	for i in connected_inputs:
		if is_instance_valid(i[0]):
			i[1].invoke(i[0], args)

func can_connect_to(object):
	return object is Card and not object.disable and object.slots.any(func (s):
		return s is InputSlot and self.num_args == s.num_args)

func connect_to(from: Node, object: Node):
	var input = object.get_input_slot()
	input.connect_to(object, from)
