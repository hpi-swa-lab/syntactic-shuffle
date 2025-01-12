@tool
#thumb("forward.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Drop Arguments",
		"Forward signals without arguments.",
		Card.Type.Effect,
		[OutputSlot.create(0), InputSlot.create(1)])
	on_invoke_input(invoke)

func invoke(obj):
	invoke_output([])
