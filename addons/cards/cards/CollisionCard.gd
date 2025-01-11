@tool
#thumb("GPUParticlesCollisionBox3D.svg")
extends Card

func _ready() -> void:
	super._ready()
	setup("Collision", "Emit signal when colliding.", Card.Type.Trigger, [
		ObjectInputSlot.new(),
		ObjectOutputSlot.create(1)
	])

func _physics_process(delta):
	if Engine.is_editor_hint() or not get_object_input_slot(): return
	var o = get_object_input()
	if o is CharacterBody2D:
		for collision_index in o.get_slide_collision_count():
			var collision = o.get_slide_collision(collision_index)
			get_object_output_slot().invoke(self, [collision])
