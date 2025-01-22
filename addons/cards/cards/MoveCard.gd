@tool
extends Card
class_name MoveCard

func s():
	title("Move")
	description("Move an object.")
	icon("move.png")
	
	var velocity_card = Vector2Card.new()
	var did_accelerate_card = BoolCard.new()
	
	var code_card = CodeCard.create(
		[["velocity", t("Vector2")], ["body", t("Node")], ["did_accelerate", t("bool")], ["trigger", trg()]],
		{"out": t("Vector2"), "did_accelerate": t("bool")},
		func (card, velocity, body, did_accelerate):
			if not did_accelerate:
				var friction = 20
				velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * get_process_delta_time()))
			if body is CharacterBody2D:
				body.velocity = velocity
				body.move_and_slide()
			elif body is Node2D:
				body.position += velocity * get_process_delta_time()
			card.output("did_accelerate", [false])
			card.output("out", [velocity]), ["body", "velocity", "did_accelerate"])
	code_card.c(velocity_card)
	code_card.c(did_accelerate_card)
	did_accelerate_card.c_named("did_accelerate", code_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)
	
	var in_character = InCard.data(t("Node"))
	in_character.c_named("body", code_card)
	
	var add_card = CodeCard.create(
		[["direction", t("Vector2")], ["velocity", t("Vector2")]],
		{"out": t("Vector2"), "did_accelerate": t("bool")},
		func (card, direction, velocity):
			var _accel = 10
			var max_velocity = 500
			if false: direction = direction.rotated(get_parent().rotation) # rotated
			var v = velocity.lerp(direction * max_velocity, min(1.0, _accel * get_process_delta_time()))
			card.output("did_accelerate", [true])
			card.output("out", [v]), ["velocity"])
	add_card.c(velocity_card)
	add_card.c(did_accelerate_card)
	
	var in_direction = InCard.data(t("Vector2"))
	in_direction.c_named("direction", add_card)
	velocity_card.c_named("velocity", add_card)
	velocity_card.c_named("velocity", code_card)
