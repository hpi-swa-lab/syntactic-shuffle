@tool
extends Card
class_name DivideCard

func v():
	title("Divide")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADtJREFUOI1j/P//PwMlgIki3TQ3gJGR8T8jIyNeP1LsAsYBD0QWZA4h/8LA////GanmgoEPg9F0QAUDAGF5FBvePfsvAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(559.931, 305.6451)
	var remember_card_2 = RememberCard.new()
	remember_card_2.position = Vector2(559.9337, 894.3524)
	var code_card = CodeCard.create([["left", t("float")], ["right", t("float")]], {"out": t("float")}, func(card, left, right):
		card.output("out", [left / right]), [])
	code_card.position = Vector2(1280.26, 599.9943)
	var in_card = InCard.data(t("float"))
	in_card.position = Vector2(200.0, 400.0)
	var in_card_2 = InCard.data(t("float"))
	in_card_2.position = Vector2(200.0, 800.0)
	var out_card = OutCard.new()
	out_card.position = Vector2(2015.692, 599.99)
	
	remember_card.c_named("right", code_card)
	remember_card_2.c_named("left", code_card)
	code_card.c(out_card)
	in_card.c(remember_card)
	in_card_2.c(remember_card_2)
