@tool
extends Card
class_name StoreCard

func v():
	title("Store")
	description("Write into a data cell.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAElJREFUOI1jYBiM4D8pipko0YzL5v9YxCgyCK8h6F5ABozk2I7LNVTT/J8UQ/8zoGqgOHDRDSdbI8W2o7gAXzTi1ESpzVQxCA4A6EcX8AnN2kcAAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.command("store")
	out_card.position = Vector2(516.228, 400.0003)
	var in_card = InCard.data(any())
	in_card.position = Vector2(200.0, 400.0)
	
	in_card.c(out_card)
