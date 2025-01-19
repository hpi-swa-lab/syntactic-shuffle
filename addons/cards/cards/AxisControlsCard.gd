@tool
extends Card
class_name AxisControlsCard

func s():
	title("Axis Controls")
	description("Emits signals for inputs on the four axes.")
	icon("keyboard_input.png")
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create({"trigger": ""}, ["Vector2"], func (card, args):
		var input_direction = Vector2.ZERO
		if _is_key_pressed("left"): input_direction += Vector2.LEFT
		if _is_key_pressed("right"): input_direction += Vector2.RIGHT
		if _is_key_pressed("up"): input_direction += Vector2.UP
		if _is_key_pressed("down"): input_direction += Vector2.DOWN
		if input_direction.length() > 0: card.output([input_direction.normalized()]))
	code_card.c(out_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)

func _is_key_pressed(direction):
	var action_string = "ui_{0}".format([direction])
	return Input.is_action_pressed(action_string)
