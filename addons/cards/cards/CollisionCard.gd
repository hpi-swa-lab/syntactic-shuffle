@tool
extends Card
class_name CollisionCard

func v():
	title("Collision")
	description("Emit when colliding.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAMZJREFUOI2Vk70NwyAQhd8ZF5acwgu4sOQkHctkhMyVETyA16BMmkgsQElHGkAnhz9/DeLEHY97B33XFUZqpHi+r8k4pwOASc3Vgzn6w94BILaGWA7qwqGUis3aUjIA/wResXJjtgAZqR1TQpOamwr1AIILxOLNKui+LMWkyzgW8489OM3Rxj9et0+cEyM1JjXjMQwEAJu19QIePhPE7W19gvMu8YYTTvYgqjBSu/B/uAtJdiHiWKc+XVHBLgS/OUm2gE+u8gPQVDm7J3Rr9wAAAABJRU5ErkJggg==")

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(1253.09, 599.9952)
	var code_card = CodeCard.create([["body", t("CharacterBody2D")], ["trigger", trg()]], {"trigger": trg()}, func (card, body):
		if body is CharacterBody2D:
			for collision_index in body.get_slide_collision_count():
				card.output("trigger", []), [])
	code_card.position = Vector2(748.1183, 588.3369)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(200.0, 400.0)
	var in_card = InCard.data(t("CharacterBody2D"))
	in_card.position = Vector2(200.0, 800.0)
	
	code_card.c(out_card)
	physics_process_card.c_named("trigger", code_card)
	in_card.c_named("body", code_card)
