@tool
extends Card
class_name Vector2Card

func v():
	title("Vector")
	description("Store or present a vector.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADNJREFUOI1jYBhs4D8BPkmGkKWZIpup4gKqhAFVATYXkOyq/zjYJBsy8NFKlsaBj0aCAABn0BLuMpwyWQAAAABJRU5ErkJggg==")

func s():
	var out_card = OutCard.remember()
	out_card.position = Vector2(1216.867, 724.936)
	var cell_card = CellCard.create("vector", "Vector2", Vector2(0.0, 0.0))
	cell_card.position = Vector2(770.6774, 738.7415)
	var store_card = StoreCard.new()
	store_card.position = Vector2(513.8918, 309.0302)
	var in_card = InCard.data(t("Vector2"))
	in_card.position = Vector2(186.9072, 301.8042)
	var in_card_2 = InCard.trigger()
	in_card_2.position = Vector2(251.7033, 705.7172)
	var named_in_card = NamedInCard.named_data("x", t("float"))
	named_in_card.position = Vector2(247.7279, 1214.506)
	var code_card = CodeCard.create([["x", t("float")], ["current", t("Vector2")]], {}, func(card, x, current):
		x, [""])
	code_card.position = Vector2(1126.809, 1448.202)
	
	cell_card.c(out_card)
	store_card.c(cell_card)
	in_card.c(store_card)
	in_card_2.c(cell_card)
