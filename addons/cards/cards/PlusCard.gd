@tool
#thumb("plus.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Plus", "Add two things.", Card.Type.Effect, [
		NamedInputSlot.new("left", {"left": ["float"]}),
		NamedInputSlot.new("right", {"right": ["float"]}),
		OutputSlot.new({"sum": ["float"]})
	])

var _left: Vector2
var _right: Vector2

func left(left: Vector2):
	_left = left
	do()

func right(right: Vector2):
	_right = right
	do()

func do():
	if _right and _left:
		invoke_output("sum", [_left + _right])
