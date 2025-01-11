extends Area2D

signal collided(body: Node2D)

var owner_group: String

@export var damage = 5
@export var velocity = 1000

func _physics_process(delta: float) -> void:
	var forward = -transform.y
	position += forward * velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(owner_group):
		return
	if body.is_in_group("health"):
		body.take_damage(damage)
	collided.emit(body)
	queue_free()
