@tool
#thumb("GPUParticlesCollisionBox3D")
extends Card

var input = Slot.ObjectInputSlot.new()
var output = Slot.ObjectOutputSlot.new()

func _ready() -> void:
	super._ready()
	setup("Collision", "Emit signal when colliding.", Card.Type.Trigger, [
		input,
		output
	])

func _physics_process(delta):
	var o = input.get_object(self)
	if input.get_object(self) is CharacterBody2D:
		for collision_index in o.get_slide_collision_count():
			var collision = o.get_slide_collision(collision_index)
			output.invoke(collision)
