@tool
extends Card

@export var group_path: NodePath

func _ready() -> void:
	super._ready()
	setup("Scene", "Create an embedded scene.", "scene.png", CardVisual.Type.Effect, [
		InputSlot.new({"spawn": ["spawn"]})
	])

func spawn():
	var node = get_node_or_null(group_path)
	if node:
		get_parent().add_child(node.instantiate())
