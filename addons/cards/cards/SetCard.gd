@tool
extends Card
class_name SetCard

@export var property_name := "":
	get: return property_name
	set(v):
		property_name = v
		#in_object_card.signature = ["@prop:{0}".format([property_name])]
		get_in_object_card().signature_changed()

func get_in_object_card():
	if not in_object_card: in_object_card = NamedInCard.named_data("value", "*")
	return in_object_card

var in_object_card: NamedInCard

func s():
	title("Set Property")
	description("Set the property of an object.")
	icon("increment.png")
	
	var code_card = CodeCard.create(["*"], func (card, args):
		print(args))
	
	var in_value_card = NamedInCard.named_data("object", "*")
	in_value_card.c(code_card)
	
	get_in_object_card().c(code_card)
