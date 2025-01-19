@tool
extends Card
class_name SetCard

@export var property_name := "":
	get: return property_name
	set(v):
		property_name = v
		if in_object_card:
			#in_object_card.signature = ["@prop:{0}".format([property_name])]
			in_object_card.signature_changed()

var in_object_card: NamedInCard

func s():
	title("Set Property")
	description("Set the property of an object.")
	icon("increment.png")
	
	in_object_card = NamedInCard.named_data("value", "*")
	# refresh
	self.property_name = property_name
	
	var code_card = CodeCard.create(["*"], func (card, args):
		print(args))
	
	var in_value_card = NamedInCard.named_data("object", "*")
	in_value_card.c(code_card)
	
	in_object_card.c(code_card)
