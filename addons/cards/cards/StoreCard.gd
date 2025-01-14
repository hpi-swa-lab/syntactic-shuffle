@tool
#thumb("number.png")
extends Card

var number: float = 0

func _ready() -> void:
	super._ready()
	setup("Store", "Stores a number.", Card.Type.Store, [
		InputSlot.new({"increment": ["increment"]}),
		OutputSlot.new({"default": ["float"]})
	])

func override(num: float):
	number = num
	invoke_output("default", [number])

func increment():
	number += 1
	invoke_output("default", [number])
