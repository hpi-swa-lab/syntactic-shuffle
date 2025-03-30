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
	
	var in_card = InCard.data(cmd("store", t("bool")))
	in_card.position = Vector2(188.3926, 341.6846)
	
	var in_card_2 = InCard.trigger()
	in_card_2.position = Vector2(242.4098, 1019.76)
	
	var in_card_3 = InCard.data(cmd("toggle", trg()))
	in_card_3.position = Vector2(165.3011, 1415.906)
	
	var out_card = OutCard.new(true)
	out_card.position = Vector2(1374.487, 421.9353)
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(562.7589, 320.4187)
	
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(986.5932, 1397.264)
	
	cell_card.c(out_card)
	cell_card.c_named("value", code_card)
	code_card.c(store_card_2)
	in_card.c(store_card)
	in_card_2.c(cell_card)
	in_card_3.c_named("trigger", code_card)
	store_card.c(cell_card)
	store_card_2.c(cell_card)
