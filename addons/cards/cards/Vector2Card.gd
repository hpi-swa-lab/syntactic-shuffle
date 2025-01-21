@tool
extends Card
class_name Vector2Card

@export var vector: Vector2

func s():
	title("Vector")
	description("Store or present a vector.")
	icon("vector.png")
	
	var out_card = OutCard.remember([vector], t("Vector2"))
	
	var cell_card = CellCard.new()
	cell_card.data = vector
	cell_card.type = "Vector2"
	cell_card.c(out_card)
	
	var store_card = StoreCard.new()
	store_card.c(cell_card)
	
	var override_card = InCard.data(t("Vector2"))
	override_card.c(store_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(cell_card)
	
	var increment_code = CodeCard.create([["amount", t("Vector2")]], {"out": none()}, func (card, amount):
		card.parent.vector += amount)
	var increment_card = InCard.command("increment", t("Vector2"))
	increment_card.c_named("amount", increment_code)
