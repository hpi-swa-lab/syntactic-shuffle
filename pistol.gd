extends Node2D

@export var owner_group: String

func shoot():
	var bullet = preload("res://bullet.tscn").instantiate()
	Spawn.spawn(bullet)
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	bullet.owner_group = owner_group
	
	# Don't play a sound at each shot. Otherwise it would be too much
	if randf() < 0.069420:
		Globals.play_sound(preload("res://resources/sounds/laserShotStandard.wav"))
