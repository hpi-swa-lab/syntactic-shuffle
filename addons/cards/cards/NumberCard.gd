@tool
extends Card
class_name NumberCard

@export var number: float

func v():
	title("Number")
	description("Store or present a number.")
	icon(preload("res://addons/cards/icons/number.png"))

func s():
	var out_card = OutCard.remember([number], t("float"))
	
	var cell_card = CellCard.new()
	cell_card.data = number
	cell_card.type = "float"
	cell_card.c(out_card)
	
	var store_card = StoreCard.new()
	store_card.c(cell_card)
	
	var store_in_card = InCard.data(cmd("store", any()))
	store_in_card.c(cell_card)
	
	var override_card = InCard.data(t("float"))
	override_card.c(store_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(cell_card)
	
	var increment_code = CodeCard.create([["trigger", trg()]], {}, func (card, trigger):
		card.parent.number += 1)
	var increment_card = InCard.data(cmd("increment"))
	increment_card.c(increment_code)

func get_stored_data():
	for card in cards:
		if card is CellCard:
			return card.data
