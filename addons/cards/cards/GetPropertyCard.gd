@tool
extends Card
class_name GetPropertyCard

func v():
	title("Get Property")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAE1JREFUOI3FkUEOgDAQAh3j/788XpsG25pqlusCWQD12MG5pf7NAFjOVR+BdoXR6ypTg9boSdCjvoPvDABn+6f7lYgqiZyKjSu8QX2JN1I+HxmHE4DeAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["property", t("String")], ["object", any()], ["trigger", trg()]], [["out", any()]], func(card, out, property, object):
		out.call(object.get(property)), ["property"])
	code_card.position = Vector2(1003.648, 263.8711)
	var cell_card = CellCard.create("property_name", "String", "")
	cell_card.position = Vector2(1010.196, 833.1957)
	var in_card = InCard.trigger()
	in_card.position = Vector2(409.3658, 227.1764)
	var out_card = OutCard.static_signature(t("Vector2"), false)
	out_card.position = Vector2(1486.923, 218.1656)
	var code_card_2 = CodeCard.create([["obj", any()], ["prop_name", t("String")]], [], func(card, obj, prop_name):
		if not obj is Object: return
		for prop in obj.get_property_list():
			if prop["name"] == prop_name:
				var t = Signature.type_signature(prop["type"])
				for c in card.parent.cards:
					if c is OutCard:
						c.has_static_signature = true
						c.signature = Signature.TypeSignature.new(t)
				return , ["prop_name"])
	code_card_2.position = Vector2(809.9025, 1322.814)
	var subscribe_in_card = SubscribeInCard.new(t("Object"))
	subscribe_in_card.position = Vector2(499.1244, 767.828)
	
	code_card.c(out_card)
	cell_card.c_named("property", code_card)
	cell_card.c_named("prop_name", code_card_2)
	in_card.c_named("trigger", code_card)
	subscribe_in_card.c_named("obj", code_card_2)
	subscribe_in_card.c_named("object", code_card)
