extends Node2D

@export var health = 20

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		die()

func show_brain(_show: bool):
	$brain.visible = _show

func die():
	queue_free()
	for child in $brain/CardBoundary.get_children():
		if child is Card:
			child.get_parent().remove_child(child)
			Spawn.spawn(child)
			child.global_position = global_position + Vector2(randf() - 0.5, randf() - 0.5) * 200
			child.locked = false
