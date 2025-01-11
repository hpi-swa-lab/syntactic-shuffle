@tool
#thumb("look_at.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Look At", "Turns the parent to look at the target.", Card.Type.Effect, [
		ObjectInputSlot.create("cards"),
		InputSlot.create(1)
	])
	on_invoke_input(turn)

func turn(target: Vector2):
	var node = get_object_input()
	if not node or not node is Node2D: return
	(node as Node2D).look_at(target)
