@tool
#thumb("Remove.svg")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete",
		"Delete a node.",
		Card.Type.Effect,
		[ObjectInputSlot.create("cards"), InputSlot.create(1)])
	on_invoke_input(invoke)

func invoke(obj):
	var input = get_object_input()
	if input: input.queue_free()
	elif "queue_free" in obj: obj.queue_free()
