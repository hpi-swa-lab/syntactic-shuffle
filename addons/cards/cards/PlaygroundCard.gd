@tool
extends Card
class_name PlaygroundCard

func v():
	title("Playground")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADBJREFUOI3t07ERwDAMw8BnzvuvTBfZwGqFnkDFoAYcaJuXcZJ+kzqsYAUr+InhnS970QYf3m3IkQAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var clock_card = ClockCard.new()
	clock_card.position = Vector2(131.6656, 51.14283)
	clock_card.get_cell("seconds").data = 1.0
	
