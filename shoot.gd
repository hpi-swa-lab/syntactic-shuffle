extends Node2D

@export var owner_group: String

func shoot():
	var bullet = preload("res://bullet.tscn").instantiate()
	Spawn.spawn(bullet)
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	bullet.owner_group = owner_group
