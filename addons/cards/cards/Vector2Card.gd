@tool
extends Card
class_name Vector2Card

func v():
	title("Vector")
	description("Store or present a vector.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADNJREFUOI1jYBhs4D8BPkmGkKWZIpup4gKqhAFVATYXkOyq/zjYJBsy8NFKlsaBj0aCAABn0BLuMpwyWQAAAABJRU5ErkJggg==")

func s():
	var out_card = OutCard.remember()
	out_card.position = Vector2(1431.055, 182.1524)
	var cell_card = CellCard.create("vector", "Vector2", Vector2(0.0, 0.0))
	cell_card.position = Vector2(956.2359, 556.02)
	var store_card = StoreCard.new()
	store_card.position = Vector2(660.1869, 222.8787)
	var in_card = InCard.data(t("Vector2"))
	in_card.position = Vector2(349.4573, 214.0271)
	var in_card_2 = InCard.trigger()
	in_card_2.position = Vector2(370.3648, 577.303)
	var named_in_card = NamedInCard.named_data("x", t("float"))
	named_in_card.position = Vector2(227.7688, 1034.294)
	var named_in_card_2 = NamedInCard.named_data("y", t("float"))
	named_in_card_2.position = Vector2(1830.787, 960.4446)
	var code_card = CodeCard.create([["number", t("float")], ["current", t("Vector2")]], {"out": t("Vector2")}, func(card, number, current):
		current.x = number
		card.output("out", [current]), ["current"])
	code_card.position = Vector2(695.4229, 1064.738)
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(1034.13, 1092.902)
	var code_card_2 = CodeCard.create([["number", t("float")], ["current", t("Vector2")]], {"out": t("Vector2")}, func(card, number, current):
		current.y = number
		card.output("out", [current]), ["current"])
	code_card_2.position = Vector2(1453.33, 953.097)
	
	cell_card.c(out_card)
	cell_card.c_named("current", code_card)
	cell_card.c_named("current", code_card_2)
	store_card.c(cell_card)
	in_card.c(store_card)
	in_card_2.c(cell_card)
	named_in_card.c_named("number", code_card)
	named_in_card_2.c_named("number", code_card_2)
	code_card.c(store_card_2)
	store_card_2.c(cell_card)
	code_card_2.c(store_card_2)
