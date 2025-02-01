@tool
extends Card
class_name NumberCard

func v():
	title("Number")
	description("Store or present a number.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAElJREFUOI1jYBiM4D8pipko0YzL5v9YxCgyCK8h6F5ABozk2I7LNVTT/J8UQ/8zoGqgOHDRDSdbI8W2o7gAXzTi1ESpzVQxCA4A6EcX8AnN2kcAAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.remember()
	out_card.position = Vector2(1368.681, 250.4749)
	var cell_card = CellCard.create("number", "float", 0.0)
	cell_card.position = Vector2(925.335, 635.4128)
	var store_card = StoreCard.new()
	store_card.position = Vector2(581.2921, 908.7749)
	var in_card = InCard.data(cmd("store", any()))
	in_card.position = Vector2(242.4098, 504.0967)
	var in_card_2 = InCard.data(t("float"))
	in_card_2.position = Vector2(238.5543, 1023.615)
	var in_card_3 = InCard.data(cmd("increment", trg()))
	in_card_3.position = Vector2(1553.494, 1162.426)
	var in_card_4 = InCard.trigger()
	in_card_4.position = Vector2(622.0853, 66.68216)
	var code_card = CodeCard.create([["trigger", trg()], ["current", t("float")]], {"out": t("float")}, 	func (card, current):
		card.output("out", [current + 1]), ["current"])
	code_card.position = Vector2(1111.923, 1198.735)
	
	cell_card.c(out_card)
	cell_card.c_named("current", code_card)
	store_card.c(cell_card)
	in_card.c(cell_card)
	in_card_2.c(store_card)
	in_card_3.c_named("trigger", code_card)
	in_card_4.c(cell_card)
	code_card.c(store_card)
