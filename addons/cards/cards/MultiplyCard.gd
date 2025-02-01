@tool
extends Card
class_name MultiplyCard

func v():
	title("Multiply")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF9JREFUOI3NkzEOwCAMA+P+/8/HVAk1cUQLQ70h4ZNxgoDY0bXlPg6QxJtzAgCqLt1mQC3AQZw5IkJuCjPEmRPAxX8mPJqgHOP85q7YElAV1kHSHri4DmI7WNXP/sIXDZnVRhNSj3pFAAAAAElFTkSuQmCC")

func s():
	var named_in_card = NamedInCard.named_data("b", t("float"))
	named_in_card.position = Vector2(302.6561, 1229.521)
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(848.9487, 1200.515)
	var code_card = CodeCard.create([["a", t("float")], ["b", t("float")]], {"out": t("float")}, func(card, a, b):
		if a != null and b != null:
			card.output("out", [a * b]), [])
	code_card.position = Vector2(1309.363, 768.8027)
	var out_card = OutCard.new()
	out_card.position = Vector2(1770.668, 754.9246)
	var remember_card_2 = RememberCard.new()
	remember_card_2.position = Vector2(736.8124, 396.7274)
	var named_in_card_2 = NamedInCard.named_data("a", t("float"))
	named_in_card_2.position = Vector2(257.1262, 425.7991)
	
	named_in_card.c(remember_card)
	remember_card.c_named("b", code_card)
	code_card.c(out_card)
	remember_card_2.c_named("a", code_card)
	named_in_card_2.c(remember_card_2)
