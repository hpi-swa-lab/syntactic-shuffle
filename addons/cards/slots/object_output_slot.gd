extends OutputSlot
class_name ObjectOutputSlot

## Output an object from your card, for example a CollisionInfo.

static func create(num_args: int) -> ObjectOutputSlot:
	var o = ObjectOutputSlot.new()
	o.num_args = num_args
	return o
