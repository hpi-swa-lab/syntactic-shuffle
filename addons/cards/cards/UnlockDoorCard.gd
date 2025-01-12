@tool
#thumb("PlayStart.svg")
extends Card

func _ready() -> void:
	super._ready()
	setup("Unlock a door",
		"Unlocks and opens the connected door when triggered.",
		Card.Type.Effect,
		[ObjectInputSlot.create("door"), InputSlot.create(0)])
	on_invoke_input(invoke)

func invoke():
	var input_door = get_object_input_slot().get_object(self)
	if input_door: input_door.unlock_door()
