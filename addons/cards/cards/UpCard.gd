@tool
extends Card
class_name UpCard

func s():
	title("Up")
	description("Output an up vector.")
	icon(preload("res://addons/cards/icons/up.png"))
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["trigger", trg()]], {"vector": t("Vector2")}, func (card):
		card.output("vector", [Vector2.UP]))
	code_card.c(out_card)
	
	var in_card = InCard.trigger()
	in_card.c_named("trigger", code_card)
