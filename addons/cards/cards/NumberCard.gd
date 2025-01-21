@tool
extends Card
class_name NumberCard

@export var number: float

func s():
	title("Number")
	description("Store or present a number.")
	icon("number.png")
	
	var out_card = OutCard.remember([number], t("float"))
	
	var cell_card = CellCard.new()
	cell_card.data = number
	cell_card.type = "float"
	cell_card.c(out_card)
	
	var store_card = StoreCard.new()
	store_card.c(cell_card)
	
	var override_card = InCard.data(t("float"))
	override_card.c(store_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(cell_card)
	
	var increment_code = CodeCard.create([["trigger", trg()]], {}, func (card, trigger):
		card.parent.number += 1)
	var increment_card = InCard.command("increment")
	increment_card.c(increment_code)
