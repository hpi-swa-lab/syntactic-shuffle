@tool
extends Card
class_name MultiplyCard

func v():
	title("Multiply")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF9JREFUOI3NkzEOwCAMA+P+/8/HVAk1cUQLQ70h4ZNxgoDY0bXlPg6QxJtzAgCqLt1mQC3AQZw5IkJuCjPEmRPAxX8mPJqgHOP85q7YElAV1kHSHri4DmI7WNXP/sIXDZnVRhNSj3pFAAAAAElFTkSuQmCC")
	container_size(Vector2(1832.76, 3130.405))

func s():
	var named_in_card = NamedInCard.named_data("b", t("float"))
	named_in_card.position = Vector2(302.6561, 1229.521)
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(848.9487, 1200.515)
	var code_card = CodeCard.create([["a", t("float")], ["b", t("float")]], [["out", t("float")]], func(card, out, a, b):
		if a != null and b != null:
			out.call(a * b), [])
	code_card.position = Vector2(1309.363, 768.8027)
	var out_card = OutCard.new()
	out_card.position = Vector2(1770.668, 754.9246)
	var remember_card_2 = RememberCard.new()
	remember_card_2.position = Vector2(736.8124, 396.7274)
	var named_in_card_2 = NamedInCard.named_data("a", t("float"))
	named_in_card_2.position = Vector2(257.1262, 425.7991)
	var named_in_card_3 = NamedInCard.named_data("b_vector", t("Vector2"))
	named_in_card_3.position = Vector2(302.6561, 2899.521)
	var remember_card_3 = RememberCard.new()
	remember_card_3.position = Vector2(848.9487, 2870.515)
	var code_card_2 = CodeCard.create([["a", t("Vector2")], ["b", t("Vector2")]], [["out", t("Vector2")]], func(card, out, a, b):
		if a != null and b != null:
			out.call(a * b), [])
	code_card_2.position = Vector2(1309.363, 2438.803)
	var remember_card_4 = RememberCard.new()
	remember_card_4.position = Vector2(736.8124, 2066.728)
	var named_in_card_4 = NamedInCard.named_data("a_vector", t("Vector2"))
	named_in_card_4.position = Vector2(257.1262, 2095.799)
	var out_card_2 = OutCard.new()
	out_card_2.position = Vector2(1701.314, 2223.332)
	
	named_in_card.c(remember_card)
	remember_card.c_named("a", code_card)
	code_card.c(out_card)
	remember_card_2.c_named("b", code_card)
	named_in_card_2.c(remember_card_2)
	named_in_card_3.c(remember_card_3)
	remember_card_3.c_named("b", code_card_2)
	code_card_2.c(out_card_2)
	remember_card_4.c_named("a", code_card_2)
	named_in_card_4.c(remember_card_4)
