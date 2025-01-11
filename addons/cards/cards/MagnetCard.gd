@tool
#thumb("Snap")
extends Card

func _ready() -> void:
	super._ready()
	var fixed = Card.FixedSlot.new()
	var output = Card.OutputSlot.new(1)
	setup(
		"Magnet",
		"Pair with a card or object and stays in its place.",
		Card.Type.Effect,
		[output, fixed, Card.InputSlot.new(func (): output.invoke(self, [fixed.get_object(self)]))])
