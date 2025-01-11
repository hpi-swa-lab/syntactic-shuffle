@tool
#thumb("Remove")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete",
		"Delete a node.",
		Card.Type.Effect,
		[Slot.InputSlot.new(func (obj): obj.queue_free())])
