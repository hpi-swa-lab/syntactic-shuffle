@tool
#thumb("increment.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Increment", "Increment.", Card.Type.Trigger, [
		InputSlot.new({"trigger": []}),
		OutputSlot.new({"default": ["increment"]})
	])

func trigger():
	invoke_output("default", [])
