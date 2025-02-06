@tool
extends Card
class_name ForwardTriggerCard

func v():
	title("Forward Trigger")
	description("Receives any data input, discards the data, and emits a trigger.")
	icon(preload("res://addons/cards/icons/forward.png"))

func s():
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["in", any()]], [["out", trg()]], func (card, out, arg): out.call(null))
	code_card.c(out_card)
	
	var in_card = NamedInCard.named_data("data", any())
	in_card.c_named("in", code_card)
