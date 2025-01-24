@tool
extends Card
class_name StoreCard

func v():
	title("Store")
	description("Write into a data cell.")
	icon(preload("res://addons/cards/icons/number.png"))

func s():
	var out_card = OutCard.command("store")
	var in_card = InCard.data(any())
	in_card.c(out_card)
