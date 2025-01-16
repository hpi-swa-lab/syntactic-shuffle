@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Increment", "Increment.", "increment.png", Card.Type.Trigger, [
		InputSlot.new({"trigger": []}),
		OutputSlot.new({"default": ["increment"]})
	])

func trigger():
	invoke_output("default", [])
