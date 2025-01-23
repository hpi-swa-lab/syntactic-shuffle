@tool
extends Card
class_name DownCard

func s():
	title("Down")
	description("Output a Down vector.")
	icon(preload("res://addons/cards/icons/down.png"))
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["trigger", trg()]], {"vector": t("Vector2")}, func (card):
		card.output("vector", [Vector2.DOWN]))
	code_card.c(out_card)
	
	var in_card = InCard.trigger()
	in_card.c_named("trigger", code_card)
