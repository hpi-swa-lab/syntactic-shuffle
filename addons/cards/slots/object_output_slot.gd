@tool
extends Slot
class_name ObjectOutputSlot

## Slot that each [Node] that is not a [Card] implicitly exposes.

func get_slot_name():
	return "__object"
