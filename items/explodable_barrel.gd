extends Node2D

@export var explosion_damage = 50.0

func use():
	if Globals.camera: Globals.camera.apply_camera_shake()
	$ExplosionAudioStreamPlayer2D.play()
	
	for body in $ExplosionArea2D.get_overlapping_bodies():
		if body.is_in_group("health"):
			body.take_damage(explosion_damage)
	
	Globals.play_sound(preload("res://resources/sounds/Explosion.wav"))
	queue_free()

func _process(delta: float) -> void:
	if randi_range(0, 200) < 2:
		use()

	
