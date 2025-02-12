@tool
extends Card
class_name IncrementCard

func v():
	title("Increment")
	description("Increment a number.")
	icon(preload("res://addons/cards/icons/increment.png"))

func s():
	var out_card = OutCard.new()

	var in_card = InCard.trigger()

	var code_card = CodeCard.create([["input", trg()]], [["out", cmd("increment")]], func(card, out):
		out.call(null), [])

	in_card.c_named("input", out_card)
	code_card.c(out_card)
