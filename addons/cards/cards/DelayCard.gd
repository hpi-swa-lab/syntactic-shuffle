@tool
#thumb("Time")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delay",
		"Delay for a given time and then forward the inputs.",
		Card.Type.Effect,
		[OutputSlot.create(1), InputSlot.create(1)])
	on_invoke_input(invoke)

func invoke(obj):
	await get_tree().create_timer(1)
	invoke_output([obj])
	
