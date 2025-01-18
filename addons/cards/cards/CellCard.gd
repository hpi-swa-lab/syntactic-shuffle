@tool
extends Card
class_name CellCard

@export var data: Variant = null

func s():
	title("Data Cell")
	description("Store or piece of data.")
	icon("number.png")
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create(["*"], func (card, args):
		data = args[0]
		card.output([args[0]]))
	code_card.c(out_card)
	
	var override_card = InCard.command("store", "*")
	override_card.c(code_card)
	
	var trigger_code_card = CodeCard.create(["*"], func (card): card.output([data]))
	trigger_code_card.c(out_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(trigger_code_card)
