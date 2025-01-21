@tool
extends Card
class_name OnEnterCard

func s():
	title("On Enter")
	description("Emit when entered.")
	icon("collision.png")
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["body", t("CharacterBody2D")]], {"trigger": trg()}, func (card, body):
		print("asdasdasdasd", body))
	code_card.c(out_card)
	
	var in_character = SubscribeInCard.create(t("Area2D"))
	in_character.c_named("body", code_card)
