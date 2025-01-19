@tool
extends Card
class_name NumberCard

@export var number: float:
	get:
		for c in cards:
			if c is CellCard: return c.data
		return 0.0
	set(v):
		for c in cards:
			if c is CellCard: c.data = v

func s():
	title("Number")
	description("Store or present a number.")
	icon("number.png")
	
	var out_card = OutCard.data()
	
	var cell_card = CellCard.new()
	cell_card.data = 0.0
	cell_card.type = "float"
	cell_card.c(out_card)
	
	var store_card = StoreCard.new()
	store_card.c(cell_card)
	
	var override_card = InCard.data("float")
	override_card.c(store_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(cell_card)
	
	var increment_code = CodeCard.create(["increment"], func (card):
		card.parent.number += 1)
	var increment_card = InCard.command("increment")
	increment_card.c(increment_code)
