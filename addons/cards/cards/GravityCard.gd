@tool
extends Card
class_name GravityCard

func v():
	title("Gravity")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFRJREFUOI1j/P//PwMlgIki3QwMDCzYBBkZGbE66////4xUd8GoAYPBAEZYSsQV97gALE0woQuQohnFAGINQVeDEQb4DCE6KWNTiMtgnLGArAGfqwD02iwHiObZSwAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(1083.499, 678.5871)
	vector_2_card.cards[1].data = Vector2(0.0, 9.81)
	var out_card = OutCard.new()
	out_card.position = Vector2(1779.638, 1164.015)
	var filter_signatures_card = FilterSignaturesCard.new(trg())
	filter_signatures_card.position = Vector2(715.6702, 691.0835)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(201.9994, 586.4481)
	var multiply_card = MultiplyCard.new()
	multiply_card.position = Vector2(1409.965, 1111.612)
	var vector_2_card_2 = Vector2Card.new()
	vector_2_card_2.position = Vector2(956.0118, 1446.213)
	vector_2_card_2.cards[1].data = Vector2(50.0, 50.0)
	
	vector_2_card.c_named("b_vector", multiply_card)
	filter_signatures_card.c(vector_2_card)
	physics_process_card.c(filter_signatures_card)
	multiply_card.c(out_card)
	vector_2_card_2.c_named("a_vector", multiply_card)
