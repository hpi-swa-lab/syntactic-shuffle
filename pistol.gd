extends Node2D

@export var owner_group: String

var last_shot = 0
@export var cooldown_msec = 1000

func shoot():
	if Time.get_ticks_msec() - last_shot < cooldown_msec:
		return
	last_shot = Time.get_ticks_msec()
	var bullet = preload("res://bullet.tscn").instantiate()
	Spawn.spawn(bullet)
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	bullet.owner_group = owner_group
	Globals.play_sound(preload("res://resources/sounds/laserShotStandard.wav"))
