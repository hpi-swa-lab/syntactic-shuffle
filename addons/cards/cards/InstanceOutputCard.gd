@tool
extends Card
class_name InstanceOutCard

func v():
	title("Instance Output")
	description("Output a template for instancing this card.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAJ1JREFUOI2NkzsSQyEIRQ9OmlQs5O1/KS7EKt0zRRIHBYy30VHuZwQBOh+s6xEkIElUGKGq8kjushRDvKq6BGKIWYoOyI8MUAzZuUQJquqUzhYPIeuQpBhc9wZf8kknOiDloHArknWB532P/avkPqnAjmQgmcCuE9MjWhsB+tUaV2uOtZyJ2ywO6SBV1eluN3ER3Jwcf5wVf4btXOQNYPgnwLpKoWsAAAAASUVORK5CYII=")
	container_size(Vector2(1200.0, 800.0))

var out_card: StaticOutCard

func allow_editing(): return false

func s():
	out_card = StaticOutCard.new("type", none(), true)

func propagate_incoming_connected(seen):
	out_card.override_signature([t(parent.card_name)])
	out_card.remember(t(parent.card_name), [parent], Invocation.GLOBAL)
	super.propagate_incoming_connected(seen)
