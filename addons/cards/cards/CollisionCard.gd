@tool
extends Card
class_name CollisionCard

func s():
	title("Collision")
	description("Emit when colliding.")
	icon(preload("res://addons/cards/icons/collision.png"))
	allow_cycles()
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["body", t("CharacterBody2D")], ["trigger", trg()]], {"trigger": trg()}, func (card, body):
		if body is CharacterBody2D:
			for collision_index in body.get_slide_collision_count():
				card.output("trigger", []))
	code_card.c(out_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)
	
	var in_character = InCard.data(t("CharacterBody2D"))
	in_character.c_named("body", code_card)
