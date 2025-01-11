@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Shoot",
		"Shoots a gun",
		Card.Type.Effect,
		[ObjectInputSlot.new(), InputSlot.create(0)])
	on_invoke_input(invoke)

func invoke(obj):
	var input = get_object_input_slot().get_object(self)
	if input: input.queue_free()
	else: obj.queue_free()
