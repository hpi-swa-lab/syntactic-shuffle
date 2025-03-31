@tool
extends Card
class_name BoolCard

func v():
	title("Bool")
	description("Store or present a boolean.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAEhJREFUOI1jYBgFjGj8/6TqQzbgPxYD4XJddxGcMmWEXpgGojWjG8JIjmZkQ5hwSxMHKDaAKmEAV0isIdhiAdkQYgAui4YiAAATwxYLHVO/dwAAAABJRU5ErkJggg==")
	container_size(Vector2(1571.487, 1697.906))

func s():
	var cell_card = CellCard.create("value", "bool", false)
	cell_card.position = Vector2(769.1019, 822.6429)
	
	var code_card = CodeCard.create([["value", t("bool")], ["trigger", cmd("toggle", trg())]], [["out", t("bool")]], func(card, out, value): out.call(not value), ["value"])
	code_card.position = Vector2(572.2458, 1388.409)
	
	var in_card = InCard.data(cmd("toggle", trg()))
	in_card.position = Vector2(165.3011, 1415.906)
	
	var in_card_2 = InCard.data(cmd("store", t("bool")))
	in_card_2.position = Vector2(209.448, 648.2452)
	
	var in_card_3 = InCard.data(t("bool"))
	in_card_3.position = Vector2(303.2902, 278.0158)
	
	var in_card_4 = InCard.trigger()
	in_card_4.position = Vector2(234.6675, 1038.341)
	
	var out_card = OutCard.new()
	out_card.position = Vector2(1374.487, 421.9353)
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(986.5932, 1397.264)
	
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(632.8219, 343.0078)
	
	cell_card.c(out_card)
	cell_card.c_named("value", code_card)
	code_card.c(store_card)
	in_card.c_named("trigger", code_card)
	in_card_2.c(cell_card)
	in_card_3.c(store_card_2)
	in_card_4.c(cell_card)
	store_card.c(cell_card)
	store_card_2.c(cell_card)
