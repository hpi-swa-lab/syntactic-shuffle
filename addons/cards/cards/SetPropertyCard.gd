@tool
extends Card
class_name SetPropertyCard

func v():
	title("Set Property")
	description("Set the property of an object.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFhJREFUOI3Nk0EKwDAIBDsl///y9CSUJG0SLDR78qCysyjqkdGZmt5zAbAUStpBmW3sOVMpvYaoVYaL6zsAnBkMpRG+CfGNOZCesBoElbvdUR5NiKv6/xcuC/8tH+UGrC4AAAAASUVORK5CYII=")

func s():
	var named_in_card = NamedInCard.named_data("value", any())
	named_in_card.position = Vector2(200.0, 400.0)
	var code_card = CodeCard.create([["value", any()], ["object", t("Object")], ["property_name", t("String")]], {"out": none()}, func (card, value, object, property_name):
		object.set(property_name, value), ["object", "property_name"])
	code_card.position = Vector2(761.4931, 837.9059)
	var named_in_card_2 = NamedInCard.named_data("object", any())
	named_in_card_2.position = Vector2(200.0, 800.0)
	var cell_card = CellCard.create("property_name", "String", "")
	cell_card.position = Vector2(1008.18, 274.9383)
	
	named_in_card.c_named("value", code_card)
	named_in_card_2.c_named("object", code_card)
	cell_card.c_named("property_name", code_card)
