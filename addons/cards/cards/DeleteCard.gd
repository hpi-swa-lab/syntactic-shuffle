@tool
#thumb("Remove")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete",
		"Delete a node.",
		Card.Type.Effect,
		[ObjectInputSlot.new(), InputSlot.create(1)])
	get_input_slot().invoke_called.connect(func (args): invoke(args[0]))

func invoke(obj):
	var input = get_object_input_slot().get_object(self)
	if input: input.queue_free()
	else: obj.queue_free()
