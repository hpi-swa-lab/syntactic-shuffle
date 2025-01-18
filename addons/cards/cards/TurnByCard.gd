@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Turn", "Rotates the parent by the given degrees.", "turn_by.png", CardVisual.Type.Effect, [
		ObjectInputSlot.new(),
		InputSlot.new({"turn": ["float"]})
	])

func turn(turn_radians: float):
	var node = get_object_input()
	if not node or not node is Node2D: return
	node.rotate(turn_radians)
	activate_object_input()
