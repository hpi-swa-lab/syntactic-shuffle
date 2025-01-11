@tool
#thumb("move.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Move", "Moves the parent around.", Card.Type.Effect, [
		ObjectInputSlot.create(),
		InputSlot.create(1)
	])
	on_invoke_input(move_direction)

var _did_accelerate = false
var velocity = Vector2.ZERO
var friction = 20

func move_direction(direction: Vector2):
	var _accel = 10
	var max_velocity = 500
	_did_accelerate = true
	if false: # rotated
		direction = direction.rotated(get_parent().rotation)
	velocity = velocity.lerp(direction * max_velocity, min(1.0, _accel * get_process_delta_time()))

func _physics_process(delta: float) -> void:
	var node = get_object_input()
	if not node: return
	
	if not _did_accelerate:
		velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * delta))
	
	if node is CharacterBody2D:
		node.velocity = velocity
		node.move_and_slide()
	elif node is PhysicsBody2D:
		node.move_and_collide(velocity * delta)
	else:
		node.position += velocity * delta
	_did_accelerate = false
