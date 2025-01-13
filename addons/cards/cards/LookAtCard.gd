@tool
#thumb("look_at.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Look At", "Turns the target to look at a position.", Card.Type.Effect, [
		ObjectInputSlot.new(),
		InputSlot.new({"turn_toward": ["Vector2"]})
	])

func turn_toward(target: Vector2):
	var node = get_object_input()
	if not node or not node is Node2D: return
	node.look_at(target)
