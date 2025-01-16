@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Collision", "Emit when colliding.", "collision.png", Card.Type.Trigger, [
		ObjectInputSlot.new(),
		OutputSlot.new({"default": []})
	])

func _physics_process(delta):
	var o = get_object_input()
	if Engine.is_editor_hint() or not o: return
	
	if o is CharacterBody2D:
		for collision_index in o.get_slide_collision_count():
			var collision = o.get_slide_collision(collision_index)
			invoke_output("default", [])
			activate_object_input()

func allow_cycles():
	return true
