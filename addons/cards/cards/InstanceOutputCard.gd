@tool
extends StaticOutCard
class_name InstanceOutCard

func _init() -> void:
	super._init("out", none(), true)

func v():
	title("Instance Output")
	description("Output a template for instancing this card.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAJ1JREFUOI2NkzsSQyEIRQ9OmlQs5O1/KS7EKt0zRRIHBYy30VHuZwQBOh+s6xEkIElUGKGq8kjushRDvKq6BGKIWYoOyI8MUAzZuUQJquqUzhYPIeuQpBhc9wZf8kknOiDloHArknWB532P/avkPqnAjmQgmcCuE9MjWhsB+tUaV2uOtZyJ2ywO6SBV1eluN3ER3Jwcf5wVf4btXOQNYPgnwLpKoWsAAAAASUVORK5CYII=")
	container_size(Vector2(1200.0, 800.0))

func allow_editing(): return false

func propagate_incoming_connected(seen):
	super.propagate_incoming_connected(seen)
	override_signature([t(parent.card_name)])
	remember(t(parent.card_name), [parent], Invocation.GLOBAL)

func serialize_constructor():
	return "{0}.new()".format([card_name])
