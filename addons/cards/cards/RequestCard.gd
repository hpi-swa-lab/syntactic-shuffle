@tool
extends Card
class_name RequestCard

func v():
	title("Request")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGhJREFUOI3VU9EKACEIc4f//8vrSTDTK857SQhC3dgWgaR06mmh/yBQuwCYvJBEBgBAP5sUkISdSOh3/OyTBU+iu2WTXfW1WqwyiLUoyIBZz8JcQqzkZmCRJMQdyesznpBEO7j/L7QJBksMRxtYmC08AAAAAElFTkSuQmCC")
	container_size(Vector2(1227.365, 801.4084))

func s():
	var cell_card = CellCard.create("path", "String", "")
	cell_card.position = Vector2(413.8345, 252.2413)
	
	var cell_card_2 = CellCard.create("method", "String", "")
	cell_card_2.position = Vector2(724.5802, 247.6262)
	
	var cell_card_3 = CellCard.create("body", "Variant", null)
	cell_card_3.position = Vector2(149.9491, 250.2921)
	
	var instance_out_card = InstanceOutCard.new()
	instance_out_card.position = Vector2(1030.365, 519.4084)
	
