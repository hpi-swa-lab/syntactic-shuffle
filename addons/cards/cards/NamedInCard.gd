@tool
extends InCard
class_name NamedInCard

static func named_data(name: String, type: String):
	var c = NamedInCard.new()
	c.signature = [type] as Array[String]
	c.input_name = name
	return c

@export var input_name: String

func s():
	title("Named Input")
	description("Receive input via a named connection.")
	icon("forward.png")
