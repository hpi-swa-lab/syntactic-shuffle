@tool
extends Card
class_name ForwardCard

func s():
	title("Forward")
	description("Receives a trigger, and emits a trigger after a short delay.")
	icon(preload("res://addons/cards/icons/forward.png"))
	allow_cycles()
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["in", trg()]], {"out": trg()}, func (card):
		await get_tree().create_timer(0.8).timeout
		card.output("out", []))
	code_card.c(out_card)
	
	var in_card = NamedInCard.named_data("trigger", trg())
	in_card.c_named("in", code_card)
