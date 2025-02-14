@tool
extends Card
class_name CollisionCard

func v():
	title("Collision")
	description("Emit when colliding.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAMZJREFUOI2Vk70NwyAQhd8ZF5acwgu4sOQkHctkhMyVETyA16BMmkgsQElHGkAnhz9/DeLEHY97B33XFUZqpHi+r8k4pwOASc3Vgzn6w94BILaGWA7qwqGUis3aUjIA/wResXJjtgAZqR1TQpOamwr1AIILxOLNKui+LMWkyzgW8489OM3Rxj9et0+cEyM1JjXjMQwEAJu19QIePhPE7W19gvMu8YYTTvYgqjBSu/B/uAtJdiHiWKc+XVHBLgS/OUm2gE+u8gPQVDm7J3Rr9wAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1253.09, 599.9952)
	
	var code_card = CodeCard.create([["body", t("CharacterBody2D")], ["trigger", trg()]], [["trigger", trg()], ["collision", t("KinematicCollision2D")]], func (card, trigger, collision, body):
		if body is CharacterBody2D:
			for collision_index in body.get_slide_collision_count():
				collision.call(body.get_slide_collision(collision_index))
				trigger.call(null), [])
	code_card.position = Vector2(748.1183, 588.3369)
	
	var in_card = InCard.data(t("CharacterBody2D"))
	in_card.position = Vector2(200.0, 800.0)
	
	var always_card = AlwaysCard.new()
	always_card.position = Vector2(227.5839, 248.4229)
	
	code_card.c(out_card)
	in_card.c_named("body", code_card)
	always_card.c_named("trigger", code_card)
