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
	icon(preload("res://addons/cards/icons/increment.png"))
	
	in_object_card = NamedInCard.named_data("value", any())
	# refresh
	self.property_name = property_name
	
	var code_card = CodeCard.create([["value", any()], ["object", any()]], {"out": none()}, func (card, value, object):
		object.set(property_name, value))
	
	var in_value_card = NamedInCard.named_data("object", any())
	in_value_card.c_named("value", code_card)
	
	in_object_card.c_named("object", code_card)
