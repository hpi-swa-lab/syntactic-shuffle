@tool
extends Card
class_name ToggleCard

func s():
	title("Toggle")
	description("Toggle a thing.")
	icon(preload("res://addons/cards/icons/bool.png"))
	
	var out_card = OutCard.command("toggle")
	var in_card = InCard.trigger()
	in_card.c(out_card)
