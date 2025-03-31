@tool
extends Card
class_name PlusCard

func v():
	title("Plus")
	description("Adds two numbers.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAChJREFUOI1jYBj24D8U4wRMlNow8AYwovHx+hebPopdQAiMhFgYBgAA8qYFDMtT4XcAAAAASUVORK5CYII=")
	container_size(Vector2(2258.193, 2693.755))

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(2015.692, 599.99)
	var code_card = CodeCard.create([["left", t("float")], ["right", t("float")]], [["out", t("float")]], func(card, out, left, right):
		if left != null and right != null: out.call(left + right)
, [])
	code_card.position = Vector2(1280.26, 599.9943)
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(559.931, 305.6451)
	var remember_card_2 = RememberCard.new()
	remember_card_2.position = Vector2(559.9337, 894.3524)
	var named_in_card = NamedInCard.named_data("left", t("float"))
	named_in_card.position = Vector2(200.0, 400.0)
	var named_in_card_2 = NamedInCard.named_data("right", t("float"))
	named_in_card_2.position = Vector2(200.0, 800.0)
	var named_in_card_3 = NamedInCard.named_data("left_vector", t("Vector2"))
	named_in_card_3.position = Vector2(208.3564, 1569.902)
	var remember_card_3 = RememberCard.new()
	remember_card_3.position = Vector2(860.7631, 1580.003)
	var code_card_2 = CodeCard.create([["left", t("Vector2")], ["right", t("Vector2")]], [["out", t("Vector2")]], func(card, out, left, right):
		if left != null and right != null: out.call(left + right)
, [])
	code_card_2.position = Vector2(1290.729, 1780.395)
	var out_card_2 = OutCard.new()
	out_card_2.position = Vector2(2024.048, 1769.892)
	var named_in_card_4 = NamedInCard.named_data("right_vector", t("Vector2"))
	named_in_card_4.position = Vector2(281.4753, 2358.477)
	var remember_card_4 = RememberCard.new()
	remember_card_4.position = Vector2(862.3184, 2336.959)
	
	code_card.c(out_card)
	remember_card.c_named("left", code_card)
	remember_card_2.c_named("right", code_card)
	named_in_card.c(remember_card)
	named_in_card_2.c(remember_card_2)
	named_in_card_3.c(remember_card_3)
	remember_card_3.c_named("left", code_card_2)
	code_card_2.c(out_card_2)
	named_in_card_4.c(remember_card_4)
	remember_card_4.c_named("right", code_card_2)
