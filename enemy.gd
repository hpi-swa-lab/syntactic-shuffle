extends Node2D

@export var health = 20

var noise = FastNoiseLite.new()
var time_alive = 0

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		queue_free()

func _on_fov_spots(object: Object) -> void:
	look_at(object.global_position)
	$Pistol.shoot()

func _process(delta: float) -> void:
	rotation += noise.get_noise_1d(time_alive) * 0.5
	time_alive += delta
