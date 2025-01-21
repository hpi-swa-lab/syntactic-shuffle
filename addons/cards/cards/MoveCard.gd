@tool
extends Card
class_name MoveCard

func s():
	title("Move")
	description("Move an object.")
	icon("move.png")
	
	var velocity_card = Vector2Card.new()
	
	var code_card = CodeCard.create([["velocity", t("Vector2")], ["body", t("Node")], ["trigger", trg()]], {"out": t("Vector2")}, func (card, velocity, body):
		var friction = 20
		velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * get_process_delta_time()))
		if body is CharacterBody2D:
			body.velocity = velocity
			body.move_and_slide()
		elif body is Node2D:
			body.position += velocity
		card.output("out", [velocity]), ["body", "velocity"])
	code_card.c(velocity_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)
	
	var in_character = InCard.data(t("Node"))
	in_character.c_named("body", code_card)
	
	var add_card = CodeCard.create([["direction", t("Vector2")], ["velocity", t("Vector2")]], {"out": t("Vector2")}, func (card, direction, velocity):
		var _accel = 10
		var max_velocity = 2000
		if false: direction = direction.rotated(get_parent().rotation) # rotated
		var v = velocity.lerp(direction * max_velocity, min(1.0, _accel * get_process_delta_time()))
		card.output("out", [v]), ["velocity"])
	add_card.c(velocity_card)
	
	var in_direction = InCard.data(t("Vector2"))
	in_direction.c_named("direction", add_card)
	velocity_card.c_named("velocity", add_card)
	velocity_card.c_named("velocity", code_card)
