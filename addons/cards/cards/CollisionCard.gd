@tool
#thumb("GPUParticlesCollisionBox3D")
extends Card

func _ready() -> void:
	super._ready()
	setup("Collision", "Emit signal when colliding.", Card.Type.Trigger)

func _physics_process(delta):
	var c = connected()
	if c is CharacterBody2D:
		for collision_index in c.get_slide_collision_count():
			var collision = c.get_slide_collision(collision_index)
			trigger1(collision.get_collider())
