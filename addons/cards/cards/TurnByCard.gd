@tool
extends Card
class_name TurnByCard

func s():
	title("Turn By")
	description("Turn by a number.")
	icon(preload("res://addons/cards/icons/turn_by.png"))
	
	var code_card = CodeCard.create([["body", t("Node2D")], ["amount", t("float")]], {}, func (card, body, amount):
		body.rotate(amount))
	
	var in_card = InCard.data(t("float"))
	in_card.c_named("amount", code_card)
	
	var body_in_card = InCard.data(t("Node2D"))
	body_in_card.c_named("body", code_card)
