@tool
extends Card
class_name CollisionCard

func s():
	title("Collision")
	description("Emit when colliding.")
	icon("collision.png")
	allow_cycles()
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create({"body": "CharacterBody2D", "trigger": ""}, [], func (card, args):
		var o = args["body"][0]
		if o is CharacterBody2D:
			for collision_index in o.get_slide_collision_count():
				card.output([]))
	code_card.c(out_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)
	
	var in_character = InCard.data("CharacterBody2D")
	in_character.c_named("body", code_card)
