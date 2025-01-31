@tool
extends Card
class_name MousePositionCard

func v():
	title("Mouse Position")
	description("Continously emits mouse position.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAHlJREFUOI3FUjESgDAII76nm/9/Wxw8egFrizrIlJYkQIvZOjhL4oF4yJ0ZjCqvCpaNyo7LEbaZmKSD206ygZO6eG9tZNLN1CBUAGAALjjzNz0oJmk6guPMRRba+VgUQejK836lIyByY8siDvzP31iJ14tUWuX/RzgAiBY0i/T1G08AAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(1190.92, 400.0026)
	var code_card = CodeCard.create([["trigger", trg()]], {"out": t("Vector2")}, func (card):
		card.output("out", [card_parent_in_world().get_global_mouse_position()]), [])
	code_card.position = Vector2(694.5817, 587.9924)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(200.0, 400.0)
	
	code_card.c(out_card)
	physics_process_card.c_named("trigger", code_card)
