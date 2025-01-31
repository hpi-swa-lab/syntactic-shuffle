@tool
extends Card
class_name MinusCard

func v():
	title("")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAC5JREFUOI1j/P//PwMlgIki3aMGDBIDWGAMRkZGkhLE////GaniAsbRlDgIDAAAVKwKGyPLwJcAAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(1719.345, 839.3982)
	var code_card = CodeCard.create([["left", t("float")], ["right", t("float")]], {"out": t("float")}, func(card, left, right):
		card.output("out", [left - right]), [])
	code_card.position = Vector2(1306.77, 786.0563)
	var named_in_card = NamedInCard.new("right", t("float"))
	named_in_card.position = Vector2(324.4932, 956.1713)
	var named_in_card_2 = NamedInCard.new("left", t("float"))
	named_in_card_2.position = Vector2(262.6898, 424.5754)
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(900.1844, 358.0801)
	var remember_card_2 = RememberCard.new()
	remember_card_2.position = Vector2(799.8857, 1102.159)
	
	code_card.c(out_card)
	named_in_card.c(remember_card_2)
	named_in_card_2.c(remember_card)
	remember_card.c_named("left", code_card)
	remember_card_2.c_named("right", code_card)
