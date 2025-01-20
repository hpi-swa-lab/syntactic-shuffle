@tool
extends Card
class_name MoveCard

func s():
	title("Move")
	description("Move an object.")
	icon("move.png")
	
	var velocity_card = Vector2Card.new()
	
	var code_card = CodeCard.create({"velocity": "Vector2", "body": "CharacterBody2D", "trigger": ""}, ["Vector2"], func (card, args):
		var o = args["body"][0]
		var v = args["velocity"][0]
		var friction = 20
		v = v.lerp(Vector2.ZERO, min(1.0, friction * get_process_delta_time()))
		o.velocity = v
		o.move_and_slide()
		card.output([v]), ["body", "velocity"])
	code_card.c(velocity_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)
	
	var in_character = InCard.data("CharacterBody2D")
	in_character.c_named("body", code_card)
	
	var add_card = CodeCard.create({"direction": "Vector2", "velocity": "Vector2"}, ["Vector2"], func (card, args):
		var direction = args["direction"][0]
		var velocity = args["velocity"][0]
		var _accel = 10
		var max_velocity = 2000
		if false: direction = direction.rotated(get_parent().rotation) # rotated
		var v = velocity.lerp(direction * max_velocity, min(1.0, _accel * get_process_delta_time()))
		card.output([v]), ["velocity"])
	add_card.c(velocity_card)
	
	var in_direction = InCard.data("Vector2")
	in_direction.c_named("direction", add_card)
	velocity_card.c_named("velocity", add_card)
	velocity_card.c_named("velocity", code_card)
