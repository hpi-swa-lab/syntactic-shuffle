@tool
extends Card

func s():
	title("Collision")
	description("Emit when colliding.")
	icon("collision.png")
	allow_cycles()
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([], func (card):
		var o = card.get_input("CharacterBody2D")
		if o is CharacterBody2D:
			for collision_index in o.get_slide_collision_count():
				card.output([]))
	code_card.c(out_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c(code_card)
	
	var in_character = InCard.data("CharacterBody2D")
	in_character.c(code_card)
