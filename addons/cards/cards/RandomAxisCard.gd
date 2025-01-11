@tool
#thumb("Joypad")
extends Card

func _ready() -> void:
	super._ready()
	setup("Random Axis Output", "Emits signals for random inputs on the four axes.", Card.Type.Trigger, [OutputSlot.create(1)])

func _is_key_pressed(direction):
	var action_string = "ui_{0}".format([direction])
	return Input.is_action_pressed(action_string)

func _process(delta: float) -> void:
	super._process(delta)
	
	if Engine.is_editor_hint():
		return
	
	get_output_slot().invoke(self, [Vector2.UP.rotated(randf() * PI * 2)])
