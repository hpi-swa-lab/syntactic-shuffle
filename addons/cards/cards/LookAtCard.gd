@tool
extends Card
class_name LookAtCard

func s():
	title("Look At")
	description("Look at the provided position.")
	icon(preload("res://addons/cards/icons/look_at.png"))
	
	var code_card = CodeCard.create([["body", t("Node2D")], ["position", t("Vector2")]], {}, func (card, body, position):
		body.look_at(position))
	
	var in_card = InCard.data(t("Vector2"))
	in_card.c_named("position", code_card)
	
	var body_in_card = InCard.data(t("Node2D"))
	body_in_card.c_named("body", code_card)
