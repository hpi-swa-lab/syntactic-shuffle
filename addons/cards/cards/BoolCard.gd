@tool
extends Card
class_name BoolCard

func v():
	title("Bool")
	description("Store or present a boolean.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAEhJREFUOI1jYBgFjGj8/6TqQzbgPxYD4XJddxGcMmWEXpgGojWjG8JIjmZkQ5hwSxMHKDaAKmEAV0isIdhiAdkQYgAui4YiAAATwxYLHVO/dwAAAABJRU5ErkJggg==")

func s():
	var out_card = OutCard.remember()
	out_card.position = Vector2(1995.88, 653.725)
	var cell_card = CellCard.create("value", "bool", false)
	cell_card.position = Vector2(769.1019, 822.6429)
	var store_card = StoreCard.new()
	store_card.position = Vector2(529.0267, 328.0356)
	var in_card = InCard.data(t("bool"))
	in_card.position = Vector2(200.0, 400.0)
	var in_card_2 = InCard.trigger()
	in_card_2.position = Vector2(200.0, 800.0)
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(1248.763, 1189.071)
	var code_card = CodeCard.create([["value", t("bool")], ["trigger", cmd("toggle", trg())]], {"out": t("bool")}, func(card, value): card.output("out", [not value]), ["value"])
	code_card.position = Vector2(566.4626, 1259.251)
	var in_card_3 = InCard.data(cmd("toggle", trg()))
	in_card_3.position = Vector2(200.0, 1200.0)
	
	cell_card.c(out_card)
	cell_card.c_named("value", code_card)
	store_card.c(cell_card)
	in_card.c(store_card)
	in_card_2.c(cell_card)
	store_card_2.c(cell_card)
	code_card.c(store_card_2)
	in_card_3.c_named("trigger", code_card)
