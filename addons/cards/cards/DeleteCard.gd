@tool
#thumb("Remove")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete",
		"Delete a node.",
		Card.Type.Effect,
		[InputSlot.create(1)])
	get_input_slot().invoke_called.connect(func (args): invoke(args[0]))

func invoke(obj):
	obj.queue_free()
