@tool
extends Card
class_name IncrementCard

func v():
	title("Increment")
	description("Increment a number.")
	icon(preload("res://addons/cards/icons/increment.png"))

func s():
	var out_card = OutCard.command("increment")
	var in_card = InCard.trigger()
	in_card.c(out_card)
