@tool
extends Card
class_name PlusCard

var remember_left_card: RememberCard
var remember_right_card: RememberCard

func s():
	title("Plus")
	description("Adds two numbers.")
	icon(preload("res://addons/cards/icons/plus.png"))
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["left", t("float")], ["right", t("float")]], {"out": t("float")}, func (card, l, r):
		if l != null and r != null: card.output("out", [l + r]))
	code_card.c(out_card)
	
	remember_left_card = RememberCard.new()
	remember_left_card.c_named("left", code_card)
	remember_right_card = RememberCard.new()
	remember_right_card.c_named("right", code_card)
	
	var left_card = NamedInCard.named_data("left", t("float"))
	left_card.c(remember_left_card)
	var right_card = NamedInCard.named_data("right", t("float"))
	right_card.c(remember_right_card)
