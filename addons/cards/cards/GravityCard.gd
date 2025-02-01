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
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(1361.938, 570.6886)
	vector_2_card.cards[1].data = Vector2(0.0, 9.8)
	
