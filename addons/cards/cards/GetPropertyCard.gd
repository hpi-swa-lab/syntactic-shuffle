@tool
extends Card
class_name GetPropertyCard

func v():
	title("Get Property")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAE1JREFUOI3FkUEOgDAQAh3j/788XpsG25pqlusCWQD12MG5pf7NAFjOVR+BdoXR6ypTg9boSdCjvoPvDABn+6f7lYgqiZyKjSu8QX2JN1I+HxmHE4DeAAAAAElFTkSuQmCC")

func s():
	var named_in_card = NamedInCard.named_data("object", any())
	named_in_card.position = Vector2(439.4243, 407.4026)
	var code_card = CodeCard.create([["property", t("String")], ["object", any()], ["trigger", trg()]], {"out": any()}, func(card, property, object):
		card.output("out", [object.get(property)]), ["property", "object"])
	code_card.position = Vector2(994.4725, 682.2709)
	var cell_card = CellCard.create("property_name", "String", "")
	cell_card.position = Vector2(1004.691, 167.0592)
	var in_card = InCard.trigger()
	in_card.position = Vector2(465.5733, 832.2944)
	var out_card = OutCard.new()
	out_card.position = Vector2(1565.832, 700.7935)
	
	named_in_card.c_named("object", code_card)
	code_card.c(out_card)
	cell_card.c_named("property", code_card)
	in_card.c_named("trigger", code_card)
