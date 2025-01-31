@tool
extends Card
class_name BoolCard

func v():
	title("Bool")
	description("Store or present a boolean.")
	icon(preload("res://addons/cards/icons/bool.png"))

func s():
	var out_card = OutCard.remember()
	
	var cell_card = CellCard.create("value", "bool", false)
	cell_card.c(out_card)
	
	var store_card = StoreCard.new()
	store_card.c(cell_card)
	
	var override_card = InCard.data(t("bool"))
	override_card.c(store_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(cell_card)
	
	var store_card_2 = StoreCard.new()
	store_card_2.c(cell_card)
	
	var toggle_code = CodeCard.create([["value", t("bool")], ["trigger", cmd("toggle", trg())]], {"out": t("bool")},
		func(card, value): card.output("out", [not value]),
		["value"])
	cell_card.c_named("value", toggle_code)
	toggle_code.c(store_card_2)
	
	var toggle_card = InCard.data(cmd("toggle"))
	toggle_card.c_named("trigger", toggle_code)
