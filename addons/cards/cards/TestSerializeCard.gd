@tool
extends Card
class_name TestSerializeCard

func v():
	title("Test Serialize")
	description("Test Serialize Description")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAChJREFUOI1jYBj24D8U4wRMlNow8AYwovHx+hebPopdQAiMhFgYBgAA8qYFDMtT4XcAAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.command("store")
	out_card.position = Vector2(0.0, 0.0)
	var out_card_2 = OutCard.new()
	out_card_2.position = Vector2(0.0, 0.0)
	var out_card_3 = OutCard.remember()
	out_card_3.position = Vector2(0.0, 0.0)
	var out_card_4 = OutCard.static_signature(trg(), false)
	out_card_4.position = Vector2(0.0, 0.0)
	var in_card = InCard.data(t("float"))
	in_card.position = Vector2(0.0, 0.0)
	var named_in_card = NamedInCard.named_data("a", t("float"))
	named_in_card.position = Vector2(0.0, 0.0)
	var plus_card = PlusCard.new()
	plus_card.position = Vector2(0.0, 0.0)
	var code_card = CodeCard.create([["body", t("CharacterBody2D")], ["trigger", trg()]], [["trigger", trg()]], func (card, trigger, body):
		if body is CharacterBody2D:
			for collision_index in body.get_slide_collision_count():
				trigger.call(null), [])
	code_card.position = Vector2(0.0, 0.0)
	
	in_card.c(out_card)
	in_card.c_named("left", plus_card)
