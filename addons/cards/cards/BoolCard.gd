@tool
extends Card
class_name BoolCard

@export var value: bool

func s():
	title("Bool")
	description("Store or present a boolean.")
	icon("bool.png")
	
	var out_card = OutCard.remember([value], ["bool"])
	
	var cell_card = CellCard.new()
	cell_card.data = value
	cell_card.type = "bool"
	cell_card.c(out_card)
	
	var store_card = StoreCard.new()
	store_card.c(cell_card)
	
	var override_card = InCard.data("bool")
	override_card.c(store_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(cell_card)
	
	var toggle_code = CodeCard.create({"bool": "bool", "trigger": ""}, ["store", "bool"],
		func(card, args): card.output([not args["bool"][0]]),
		["bool"])
	cell_card.c_named("bool", toggle_code)
	toggle_code.c(cell_card)
	
	var toggle_card = InCard.command("toggle")
	toggle_card.c_named("trigger", toggle_code)
