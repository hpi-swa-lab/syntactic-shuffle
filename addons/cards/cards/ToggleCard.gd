@tool
extends Card
class_name ToggleCard

func v():
	title("Toggle")
	description("Toggle a thing.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAEhJREFUOI1jYBgFjGj8/6TqQzbgPxYD4XJddxGcMmWEXpgGojWjG8JIjmZkQ5hwSxMHKDaAKmEAV0isIdhiAdkQYgAui4YiAAATwxYLHVO/dwAAAABJRU5ErkJggg==")

func s():
	var out_card = OutCard.command("toggle")
	out_card.position = Vector2(1018.321, 525.9573)
	var in_card = InCard.trigger()
	in_card.position = Vector2(606.4596, 532.9547)
	
	in_card.c(out_card)
