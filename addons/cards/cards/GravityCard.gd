@tool
extends Card
class_name GravityCard

func v():
	title("Gravity")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFRJREFUOI1j/P//PwMlgIki3QwMDCzYBBkZGbE66////4xUd8GoAYPBAEZYSsQV97gALE0woQuQohnFAGINQVeDEQb4DCE6KWNTiMtgnLGArAGfqwD02iwHiObZSwAAAABJRU5ErkJggg==")

func s():
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(1364.86, 770.2429)
	vector_2_card.cards[1].data = Vector2(0.0, 0.98)
	var out_card = OutCard.new()
	out_card.position = Vector2(1771.113, 778.2087)
	var filter_signatures_card = FilterSignaturesCard.new(trg())
	filter_signatures_card.position = Vector2(715.6702, 691.0835)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(201.9994, 586.4481)
	
	vector_2_card.c(out_card)
	filter_signatures_card.c(vector_2_card)
	physics_process_card.c(filter_signatures_card)
