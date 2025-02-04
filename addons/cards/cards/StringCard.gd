@tool
extends Card
class_name StringCard

func v():
	title("String")
	description("Store or present a number.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFNJREFUOI3VkkEKgDAQA2fE/385nloEWyuUiu4x7IbJEpMwM9vUdc9AfYy1huBVA4GaN4lw/UESWxrAPlo460VbF+GOpktYmqimhTgk+GaV/2VwAKZ8MQ+Fi34XAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var out_card = OutCard.remember()
	out_card.position = Vector2(1368.681, 250.4749)
	var cell_card = CellCard.create("string", "String", "")
	cell_card.position = Vector2(925.335, 635.4128)
	var store_card = StoreCard.new()
	store_card.position = Vector2(581.2921, 908.7749)
	var in_card = InCard.data(cmd("store", t("String")))
	in_card.position = Vector2(242.4098, 504.0967)
	var in_card_2 = InCard.data(t("String"))
	in_card_2.position = Vector2(238.5543, 1023.615)
	var in_card_3 = InCard.trigger()
	in_card_3.position = Vector2(622.0853, 66.68216)
	
	cell_card.c(out_card)
	store_card.c(cell_card)
	in_card.c(cell_card)
	in_card_2.c(store_card)
	in_card_3.c(cell_card)
