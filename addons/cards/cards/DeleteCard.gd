@tool
#thumb("Remove.svg")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete",
		"Delete a node.",
		Card.Type.Effect,
		[ObjectInputSlot.new(), InputSlot.new({"delete_input": [], "delete_arg": ["Node"]})])

func delete_input():
	var input = get_object_input()
	if input: delete_arg(input)

func delete_arg(obj):
	obj.queue_free()
