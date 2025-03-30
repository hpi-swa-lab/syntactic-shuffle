@tool
extends Card
class_name Vector2Card

func v():
	title("Vector2")
	description("Store or present a vector.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADNJREFUOI1jYBhs4D8BPkmGkKWZIpup4gKqhAFVATYXkOyq/zjYJBsy8NFKlsaBj0aCAABn0BLuMpwyWQAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var cell_card = CellCard.create("vector", "Vector2", Vector2(0.0, 0.0))
	cell_card.position = Vector2(956.2359, 556.02)
	
	var code_card = CodeCard.create([["number", t("float")], ["current", t("Vector2")]], [["out", t("Vector2")]], func(card, out, number, current):
		current.x = number
		out.call(current), ["current"])
	code_card.position = Vector2(695.4229, 1064.738)
	
	var code_card_2 = CodeCard.create([["number", t("float")], ["current", t("Vector2")]], [["out", t("Vector2")]], func(card, out, number, current):
		current.y = number
		out.call(current), ["current"])
	code_card_2.position = Vector2(1453.33, 953.097)
	
	var in_card = InCard.trigger()
	in_card.position = Vector2(370.3648, 577.303)
	
	var in_card_2 = InCard.data(t("Vector2"))
	in_card_2.position = Vector2(351.0504, 174.1982)
	
	var in_card_3 = InCard.data(cmd("store", t("Vector2")))
	in_card_3.position = Vector2(915.8929, -114.7703)
	
	var named_in_card = NamedInCard.named_data("x", t("float"))
	named_in_card.position = Vector2(227.7688, 1034.294)
	
	var named_in_card_2 = NamedInCard.named_data("y", t("float"))
	named_in_card_2.position = Vector2(1830.787, 960.4446)
	
	var out_card = OutCard.new(true)
	out_card.position = Vector2(1431.055, 182.1524)
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(660.1869, 222.8787)
	
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(1034.13, 1092.902)
	
	cell_card.c(out_card)
	cell_card.c_named("current", code_card)
	cell_card.c_named("current", code_card_2)
	code_card.c(store_card_2)
	code_card_2.c(store_card_2)
	in_card.c(cell_card)
	in_card_2.c(store_card)
	in_card_3.c(cell_card)
	named_in_card.c_named("number", code_card)
	named_in_card_2.c_named("number", code_card_2)
	store_card.c(cell_card)
	store_card_2.c(cell_card)
