@tool
extends Card
class_name MoveCard

func v():
	title("Move")
	description("Move an object.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFJJREFUOI1jYMAP/kMxTsBIQDNBtbgMwGUrhnomPC4gClDsBWQXEAwwbOoYkQTJAYyMFGhmYGCgYiBS5AUYgBmCy1B0cUZkQWxgpKREQoBg6gQAJZ0UCnXgLU8AAAAASUVORK5CYII=")
	container_size(Vector2(2142.648, 3101.768))

func s():
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(868.3738, 1344.398)
	vector_2_card.cards[1].data = Vector2(0.0, 0.0)
	var bool_card = BoolCard.new()
	bool_card.position = Vector2(1219.58, 428.579)
	bool_card.cards[0].data = false
	var code_card = CodeCard.create([["velocity", t("Vector2")], ["body", t("Node")], ["did_accelerate", t("bool")], ["trigger", trg()]], {"out": t("Vector2"), "did_accelerate": t("bool")}, func (card, velocity, body, did_accelerate):
			if not did_accelerate:
				var friction = 20
				velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * card.card_parent_in_world().get_process_delta_time()))
			if body is CharacterBody2D:
				body.velocity = velocity
				body.move_and_slide()
			elif body is Node2D:
				body.position += velocity * get_process_delta_time()
			card.output("did_accelerate", [false])
			card.output("out", [velocity]), ["body", "velocity", "did_accelerate"])
	code_card.position = Vector2(622.4604, 637.1277)
	var in_card = InCard.data(t("Node"))
	in_card.position = Vector2(161.7643, 967.2809)
	var code_card_2 = CodeCard.create([["direction", t("Vector2")], ["velocity", t("Vector2")]], {"out": t("Vector2"), "did_accelerate": t("bool")}, func (card, direction, velocity):
			var _accel = 10
			var max_velocity = 500
			# if false: direction = direction.rotated(get_parent().rotation) # rotated
			var v = velocity.lerp(direction * max_velocity, min(1.0, _accel * card.card_parent_in_world().get_process_delta_time()))
			card.output("did_accelerate", [true])
			card.output("out", [v]), ["velocity"])
	code_card_2.position = Vector2(1386.606, 1125.075)
	var in_card_2 = InCard.data(cmd("direction", t("Vector2")))
	in_card_2.position = Vector2(1773.955, 1012.023)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(133.5331, 301.9212)
	var store_card = StoreCard.new()
	store_card.position = Vector2(902.5308, 172.4603)
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(1000.191, 928.6358)
	var in_card_3 = InCard.data(t("Vector2"))
	in_card_3.position = Vector2(488.5964, 2800.957)
	var plus_card = PlusCard.new()
	plus_card.position = Vector2(970.9268, 2448.927)
	var store_card_3 = StoreCard.new()
	store_card_3.position = Vector2(1729.221, 2429.319)
	var blank_card = BlankCard.new()
	blank_card.position = Vector2(584.6162, 1886.556)
	
	vector_2_card.c(blank_card)
	vector_2_card.c_named("velocity", code_card_2)
	vector_2_card.c_named("velocity", code_card)
	bool_card.c_named("did_accelerate", code_card)
	code_card.c(store_card)
	code_card.c(store_card_2)
	in_card.c_named("body", code_card)
	code_card_2.c(store_card_2)
	code_card_2.c(bool_card)
	in_card_2.c_named("direction", code_card_2)
	physics_process_card.c_named("trigger", code_card)
	store_card.c(bool_card)
	store_card_2.c(vector_2_card)
	in_card_3.c_named("left_vector", plus_card)
	blank_card.c_named("left", plus_card)
