@tool
#thumb("slide_horizontally.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Slide Vertically", "Slides the entity horizontally.", Card.Type.Effect, [
		ObjectInputSlot.create("slide"),
		InputSlot.create(1)
	])
	on_invoke_input(slide)

var _did_accelerate = false
var velocity_x = 0.0
var friction = 20

func slide(direction: float):
	var _accel = 10
	var max_velocity = 10
	_did_accelerate = true
	velocity_x = lerp(velocity_x, direction * max_velocity, min(1.0, _accel * get_process_delta_time()))
	get_object_input_slot().on_activated(self)

func _physics_process(delta: float) -> void:
	var node = get_object_input()
	if not node: return
	
	var velocity = Vector2(velocity_x)
	if not _did_accelerate:
		velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * delta))
	
	if node is CharacterBody2D:
		node.velocity = velocity
		node.move_and_slide()
	elif node is RigidBody2D:
		node.move_and_collide(velocity * delta)
	else:
		node.position += velocity * delta
	_did_accelerate = false
