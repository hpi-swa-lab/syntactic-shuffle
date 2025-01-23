@tool
extends Card
class_name RightCard

func s():
	title("Right")
	description("Output a right vector.")
	icon(preload("res://addons/cards/icons/right.png"))
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["trigger", trg()]], {"vector": t("Vector2")}, func (card):
		card.output("vector", [Vector2.RIGHT]))
	code_card.c(out_card)
	
	var in_card = InCard.trigger()
	in_card.c_named("trigger", code_card)
