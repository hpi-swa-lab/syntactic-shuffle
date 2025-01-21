@tool
extends Card
class_name RememberCard

var out_card: OutCard

func s():
	title("Remember")
	description("Receives an input and makes sure it is remembered.")
	icon("number.png")
	
	out_card = OutCard.remember()
	
	var in_card = InCard.data(any())
	in_card.c(out_card)

func get_remembered():
	return out_card.get_remembered()
