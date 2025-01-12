extends Node2D

@export var explosion_damage = 50.0
@export var health = 5.0

func use():
	if Globals.camera: Globals.camera.apply_camera_shake()
	$ExplosionAudioStreamPlayer2D.play()
	
	for body in $ExplosionArea2D.get_overlapping_bodies():
		if body.is_in_group("health") and body != self:
			body.take_damage(explosion_damage)
	
	Globals.play_sound(preload("res://resources/sounds/Explosion.wav"))
	queue_free()


func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0.0:
		use()
		
	
	
