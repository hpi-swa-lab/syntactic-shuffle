@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Axis Controls", "Emits signals for inputs on the four axes.", "keyboard_input.png", Card.Type.Trigger, [
		OutputSlot.new({"vector": ["Vector2"]})
	])

func _is_key_pressed(direction):
	var action_string = "ui_{0}".format([direction])
	return Input.is_action_pressed(action_string)

func _process(delta: float) -> void:
	super._process(delta)
	
	if Engine.is_editor_hint():
		return
	
	var input_direction = Vector2.ZERO # Used to allow vertical movement
	if _is_key_pressed("left"):
		input_direction += Vector2.LEFT
	if _is_key_pressed("right"):
		input_direction += Vector2.RIGHT
	if _is_key_pressed("up"):
		input_direction += Vector2.UP
	if _is_key_pressed("down"):
		input_direction += Vector2.DOWN
	
	input_direction = input_direction.normalized()
	
	
	if input_direction.length() > 0:
		invoke_output("vector", [input_direction])
