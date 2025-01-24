@tool
extends Card
class_name ApplyImpulseCard

func s():
	title("Impulse")
	description("Apply an impulse to an object.")
	icon(preload("res://addons/cards/icons/impulse.png"))
	
	var code_card = CodeCard.create([["body", t("RigidBody2D")], ["toward", t("Vector2")]], {}, func (card, body: RigidBody2D, toward: Vector2):
		body.apply_impulse((toward - body.global_position).normalized() * 1000))
	
	var trigger_card = InCard.data(t("Vector2"))
	trigger_card.c_named("toward", code_card)
	
	var in_character = InCard.data(t("RigidBody2D"))
	in_character.invert_connection = true
	in_character.c_named("body", code_card)
