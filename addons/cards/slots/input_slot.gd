@tool
extends Slot
class_name InputSlot
## Provide an input from another card's output.

signal invoke_called(args: Array)

static func create(num_args: int) -> InputSlot:
	var i = InputSlot.new()
	i.num_args = num_args
	return i

func can_connect_to(object):
	return object is Card and not object.disable and object.slots.any(func (s):
		return s is OutputSlot and self.num_args == s.num_args)
func connect_to(from: Node, object: Node):
	var output = object.get_output_slot()
	output.connect_to(object, from)
func invoke(args):
	invoke_called.emit(args)
