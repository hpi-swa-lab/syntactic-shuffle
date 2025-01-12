@tool
#thumb("turn_by.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Turn", "Rotates the parent by the given degrees.", Card.Type.Effect, [
		ObjectInputSlot.create("cards"),
		InputSlot.create(1)
	])
	on_invoke_input(turn)
	print("Turn ready")

func turn(turn_radians: float):
	var node = get_object_input()
	if not node or not node is Node2D: return
	(node as Node2D).rotate(turn_radians)
