@tool
extends Card
class_name RememberCard

var out_card: OutCard

func v():
	title("Remember")
	description("Receives an input and makes sure it is remembered.")
	icon(preload("res://addons/cards/icons/number.png"))

func s():
	out_card = OutCard.remember()
	
	var in_card = InCard.data(any())
	in_card.c(out_card)

func get_remembered():
	return out_card.get_remembered()
