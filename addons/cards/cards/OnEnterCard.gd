@tool
extends Card
class_name OnEnterCard

func v():
	title("On Enter")
	description("Emit when entered.")
	icon(preload("res://addons/cards/icons/collision.png"))

func s():
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["body", t("Node2D")]], [["trigger", trg()]], func (card, out, body):
		out.call(null))
	code_card.c(out_card)
	
	var signal_card = SignalCard.new()
	signal_card.signal_name = "body_entered"
	signal_card.type = "Node2D"
	signal_card.c_named("body", code_card)
	
	var in_character = InCard.data(t("Area2D"))
	in_character.c(signal_card)
