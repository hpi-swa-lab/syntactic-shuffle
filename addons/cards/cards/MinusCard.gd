@tool
extends Card
class_name MinusCard

func v():
	title("")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAC5JREFUOI1j/P//PwMlgIki3aMGDBIDWGAMRkZGkhLE////GaniAsbRlDgIDAAAVKwKGyPLwJcAAAAASUVORK5CYII=")
	container_size(Vector2(2051.834, 2956.327))

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(1719.345, 839.3982)
	var code_card = CodeCard.create([["left", t("float")], ["right", t("float")]], {"out": t("float")}, func(card, left, right):
		card.output("out", [left - right]), [])
	code_card.position = Vector2(1306.77, 786.0563)
	var named_in_card = NamedInCard.named_data("right", t("float"))
	named_in_card.position = Vector2(324.4932, 956.1713)
	var named_in_card_2 = NamedInCard.named_data("left", t("float"))
	named_in_card_2.position = Vector2(262.6898, 424.5754)
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(900.1844, 358.0801)
	var remember_card_2 = RememberCard.new()
	remember_card_2.position = Vector2(799.8857, 1102.159)
	var named_in_card_3 = NamedInCard.named_data("left_vector", t("Vector2"))
	named_in_card_3.position = Vector2(321.4366, 1647.001)
	var named_in_card_4 = NamedInCard.named_data("right_vector", t("Vector2"))
	named_in_card_4.position = Vector2(350.5749, 2392.465)
	var remember_card_3 = RememberCard.new()
	remember_card_3.position = Vector2(887.2119, 1724.705)
	var remember_card_4 = RememberCard.new()
	remember_card_4.position = Vector2(865.3576, 2492.021)
	var code_card_2 = CodeCard.create([["left", t("Vector2")], ["right", t("Vector2")]], {"out": t("Vector2")}, func(card, l, r):
		if l != null and r != null:
			card.output("out", [l - r]), [])
	code_card_2.position = Vector2(1360.715, 2035.667)
	var out_card_2 = OutCard.new()
	out_card_2.position = Vector2(1775.411, 2030.328)
	
	code_card.c(out_card)
	named_in_card.c(remember_card_2)
	named_in_card_2.c(remember_card)
	remember_card.c_named("left", code_card)
	remember_card_2.c_named("right", code_card)
	named_in_card_3.c(remember_card_3)
	named_in_card_4.c(remember_card_4)
	remember_card_3.c_named("left", code_card_2)
	remember_card_4.c_named("right", code_card_2)
	code_card_2.c(out_card_2)
