@tool
extends Card
class_name TestSerializeCard

func v():
	title("Test Serialize")
	description("Test Serialize Description")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAChJREFUOI1jYBj24D8U4wRMlNow8AYwovHx+hebPopdQAiMhFgYBgAA8qYFDMtT4XcAAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.command("store")
	var out_card_2 = OutCard.new()
	var out_card_3 = OutCard.remember()
	var in_card = InCard.data(t("float"))
	var named_in_card = NamedInCard.named_data("a", t("float"))
	var plus_card = PlusCard.new()
	var code_card = CodeCard.create([["a", trg()], ["b", t("float")]], {"out": trg()}, func (card, a, b):
		card.output("out", [a + b]), ["a"])
	
	in_card.c(out_card)
	in_card.c_named("left", plus_card)
