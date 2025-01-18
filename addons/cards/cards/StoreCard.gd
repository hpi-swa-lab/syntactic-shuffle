@tool
extends Card
class_name StoreCard

func s():
	title("Store")
	description("Write into a data cell.")
	icon("number.png")

	var out_card = OutCard.command("store")
	var in_card = InCard.data("*")
	in_card.c(out_card)
