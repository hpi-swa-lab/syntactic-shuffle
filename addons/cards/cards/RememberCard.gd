@tool
extends Card
class_name RememberCard

func v():
	title("Remember")
	description("Receives an input and makes sure it is remembered.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAEpJREFUOI3Nk9EKACAIA73o/395vUaELAxqz/OYDpEUFbXStAsABGyjNse0wo4TZJDyDbpjkoQNcO4w6/4KWdyISy38BXjfAtV3HkzVFS/23UvPAAAAAElFTkSuQmCC")
	container_size(Vector2(815.9001, 791.967))

func s():
	var out_card = OutCard.new(true)
	out_card.position = Vector2(516.228, 400.0003)
	
	var in_card = InCard.data(any(""))
	in_card.position = Vector2(200.0, 400.0)
	
	in_card.c(out_card)
