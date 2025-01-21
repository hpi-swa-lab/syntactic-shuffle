@tool
extends Card
class_name DeleteCard

func s():
	title("Delete")
	description("Delete an object.")
	icon("delete.png")
	
	var code_card = CodeCard.create([["body", t("Node")], ["trigger", trg()]], {}, func (card, body):
		body.queue_free())
	
	var trigger_card = InCard.trigger()
	trigger_card.c_named("trigger", code_card)
	
	var in_character = InCard.data(t("Node"))
	in_character.c_named("body", code_card)
