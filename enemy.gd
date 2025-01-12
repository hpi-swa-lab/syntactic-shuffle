extends Node2D

@export var health = 20

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		queue_free()
