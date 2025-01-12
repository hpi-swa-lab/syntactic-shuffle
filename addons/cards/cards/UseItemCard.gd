@tool
#thumb("PlayStart.svg")
extends Card

func _ready() -> void:
	super._ready()
	setup("Use Item",
		"Activates or uses an connected item if triggered.",
		Card.Type.Effect,
		[ObjectInputSlot.create("useable_item"), InputSlot.create(0)])
	on_invoke_input(invoke)

func invoke():
	var item = get_object_input_slot().get_object(self)
	if item: item.use()
