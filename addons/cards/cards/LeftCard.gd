@tool
extends Card
class_name LeftCard

func s():
	title("Left")
	description("Output a left vector.")
	icon(preload("res://addons/cards/icons/left.png"))
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["trigger", trg()]], {"vector": t("Vector2")}, func (card):
		card.output("vector", [Vector2.LEFT]))
	code_card.c(out_card)
	
	var in_card = InCard.trigger()
	in_card.c_named("trigger", code_card)
