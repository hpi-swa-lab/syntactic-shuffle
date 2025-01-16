@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Minus", "Subtract two things.", "minus.png", Card.Type.Effect, [
		NamedInputSlot.new("left", {"left": ["float"]}),
		NamedInputSlot.new("right", {"right": ["float"]}),
		OutputSlot.new({"difference": ["float"]})
	])

var _left: float
var _right: float

func left(left: float):
	_left = left
	do()

func right(right: float):
	_right = right
	do()

func do():
	if _right != null and _left != null:
		invoke_output("difference", [_left - _right])
