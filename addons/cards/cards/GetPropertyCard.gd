@tool
extends Card
class_name GetPropertyCard

func v():
	title("Get Property")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAE1JREFUOI3FkUEOgDAQAh3j/788XpsG25pqlusCWQD12MG5pf7NAFjOVR+BdoXR6ypTg9boSdCjvoPvDABn+6f7lYgqiZyKjSu8QX2JN1I+HxmHE4DeAAAAAElFTkSuQmCC")
	container_size(Vector2(1793.883, 2572.993))

func s():
	var code_card = CodeCard.create([["property", t("String")], ["object", any("")], ["trigger", trg()]], [["out", any("")]], func(card, out, property, object):
		if property and property in object: out.call(object.get(property)), ["property"])
	code_card.position = Vector2(960.6461, 423.2308)
	
	var cell_card = CellCard.create("property_name", "String", "")
	cell_card.position = Vector2(696.1046, 1093.738)
	
	var in_card = InCard.trigger()
	in_card.position = Vector2(366.3639, 386.5361)
	
	var out_card = OutCard.new()
	out_card.position = Vector2(1592.829, 272.5262)
	
	var code_card_2 = CodeCard.create([["obj", any("")], ["prop_name", t("String")]], [], func(card, obj, prop_name):
		if not obj is Object: return
		for prop in obj.get_property_list():
			if prop["name"] == prop_name:
				var t = Signature.signature_for_type(prop["type"])
				for c in card.parent.cards:
					if c is CodeCard:
						for c2 in c.get_outputs(): c2.override_signature([t] as Array[Signature])
				return, ["prop_name"])
	code_card_2.position = Vector2(1074.263, 1085.087)
	
	var subscribe_in_card = SubscribeInCard.new(t("Object"))
	subscribe_in_card.position = Vector2(1408.753, 1003.551)
	
	var in_card_2 = InCard.data(t("Dictionary"))
	in_card_2.position = Vector2(297.7809, 1839.733)
	
	var code_card_3 = CodeCard.create([["property", t("String")], ["object", t("Dictionary")], ["trigger", trg()]], [["out", any("")]], func(card, out, property, object):
		if property and property in object:
			var res = object.get(property)
			for c in card.get_outputs():
				c.override_signature(Signature.signature_for_value(res))
			out.call(res), ["property"])
	code_card_3.position = Vector2(771.9716, 1767.601)
	
	var in_card_3 = InCard.trigger()
	in_card_3.position = Vector2(325.809, 2272.339)
	
	var out_card_2 = OutCard.new()
	out_card_2.position = Vector2(1327.194, 1787.252)
	
	code_card.c(out_card)
	cell_card.c_named("property", code_card)
	cell_card.c_named("property", code_card_3)
	cell_card.c_named("prop_name", code_card_2)
	in_card.c_named("trigger", code_card)
	subscribe_in_card.c_named("obj", code_card_2)
	subscribe_in_card.c_named("object", code_card)
	in_card_2.c_named("object", code_card_3)
	code_card_3.c(out_card_2)
	in_card_3.c_named("trigger", code_card_3)
