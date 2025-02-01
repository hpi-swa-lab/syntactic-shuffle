@tool
extends Card
class_name GravityCard

func v():
	title("Gravity")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFRJREFUOI1j/P//PwMlgIki3QwMDCzYBBkZGbE66////4xUd8GoAYPBAEZYSsQV97gALE0woQuQohnFAGINQVeDEQb4DCE6KWNTiMtgnLGArAGfqwD02iwHiObZSwAAAABJRU5ErkJggg==")

func s():
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(385.335, 436.8636)
	var multiply_card = MultiplyCard.new()
	multiply_card.position = Vector2(807.3732, 784.7896)
	var number_card = NumberCard.new()
	number_card.position = Vector2(386.78, 1224.734)
	number_card.cards[1].data = 9.81000000238419
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(1364.86, 770.2429)
	vector_2_card.cards[1].data = Vector2(0.0, 0.1635)
	var out_card = OutCard.new()
	out_card.position = Vector2(1771.113, 778.2087)
	
	physics_process_card.c_named("b", multiply_card)
	multiply_card.c_named("y", vector_2_card)
	number_card.c_named("a", multiply_card)
	vector_2_card.c(out_card)
