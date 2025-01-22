@tool
extends Card
class_name StoreCard

func s():
	title("Store")
	description("Write into a data cell.")
	icon(preload("res://addons/cards/icons/number.png"))

	var out_card = OutCard.command("store")
	var in_card = InCard.data(any())
	in_card.c(out_card)
