@tool
extends Card
class_name PlusCard

var remember_left_card: RememberCard
var remember_right_card: RememberCard

func s():
	title("Plus")
	description("Adds two numbers.")
	icon("plus.png")
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create(["float"], func (card: CodeCard):
		var l = remember_left_card.get_remembered()
		var r = remember_right_card.get_remembered()
		if l and r: card.output([l[0] + r[0]]))
	code_card.c(out_card)
	
	remember_left_card = RememberCard.new()
	remember_left_card.c(code_card)
	remember_right_card = RememberCard.new()
	remember_right_card.c(code_card)
	
	var left_card = NamedInCard.named_data("left", "float")
	left_card.c(remember_left_card)
	var right_card = NamedInCard.named_data("right", "float")
	right_card.c(remember_right_card)
