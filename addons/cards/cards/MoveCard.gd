@tool
extends Card
class_name MoveCard

func v():
	title("Move")
	description("Move an object.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFJJREFUOI1jYMAP/kMxTsBIQDNBtbgMwGUrhnomPC4gClDsBWQXEAwwbOoYkQTJAYyMFGhmYGCgYiBS5AUYgBmCy1B0cUZkQWxgpKREQoBg6gQAJZ0UCnXgLU8AAAAASUVORK5CYII=")
	container_size(Vector2(2007.247, 2969.129))

func s():
	var always_card = AlwaysCard.new()
	always_card.position = Vector2(292.4666, 383.438)
	
	var bool_card = BoolCard.new()
	bool_card.position = Vector2(1219.58, 428.579)
	bool_card.get_cell("value").data = false
	
	var code_card = CodeCard.create([["direction", cmd("direction", t("Vector2"))], ["velocity", t("Vector2")]], [["out", t("Vector2")], ["did_accelerate", t("bool")]], func (card, out, did_accelerate, direction, velocity):
		var _accel = 10
		var max_velocity = 500
		# if false: direction = direction.rotated(get_parent().rotation) # rotated
		var v = velocity.lerp(direction * max_velocity, min(1.0, _accel * card.card_parent_in_world().get_process_delta_time()))
		did_accelerate.call(true)
		out.call(v)
, ["velocity"])
	code_card.position = Vector2(1386.606, 1125.075)
	
	var code_card_2 = CodeCard.create([["velocity2", t("Vector2")], ["body", t("Node")], ["did_accelerate", t("bool")], ["trigger", trg()]], [["out", t("Vector2")], ["out_accelerated", t("bool")]], func (card, out, out_accelerated, velocity2, body, did_accelerate):
		if not did_accelerate:
			var friction = 20
			velocity2 = velocity2.lerp(Vector2.ZERO, min(1.0, friction * card.card_parent_in_world().get_process_delta_time()))
		if body is CharacterBody2D and body.is_inside_tree():
			body.velocity = velocity2
			body.move_and_slide()
			velocity2 = body.velocity
		elif body is Node2D:
			body.position += velocity2 * card.card_parent_in_world().get_process_delta_time()
		out_accelerated.call(false)
		out.call(velocity2)
, ["velocity2", "body", "did_accelerate"])
	code_card_2.position = Vector2(622.4604, 637.1277)
	
	var in_card = InCard.data(t("Vector2"))
	in_card.position = Vector2(341.0815, 2687.129)
	
	var in_card_2 = InCard.data(cmd("direction", t("Vector2")))
	in_card_2.position = Vector2(1810.247, 1129.693)
	
	var in_card_3 = InCard.data(t("Node"))
	in_card_3.position = Vector2(171.4733, 993.1715)
	
	var plus_card = PlusCard.new()
	plus_card.position = Vector2(900.6112, 2479.565)
	
	var pull_only_card = PullOnlyCard.new()
	pull_only_card.position = Vector2(454.9027, 1920.42)
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(1304.446, 1927.079)
	
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(1000.191, 928.6358)
	
	var store_card_3 = StoreCard.new()
	store_card_3.position = Vector2(1697.429, 563.8802)
	
	var store_card_4 = StoreCard.new()
	store_card_4.position = Vector2(842.0741, 169.1924)
	
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(869.269, 1318.908)
	vector_2_card.get_cell("vector").data = Vector2(0.0, 0.0)
	
	always_card.c_named("trigger", code_card_2)
	bool_card.c_named("did_accelerate", code_card_2)
	code_card.c(store_card_2)
	code_card.c(bool_card)
	code_card.c(store_card_3)
	code_card_2.c(store_card_4)
	code_card_2.c(store_card_2)
	in_card.c_named("left_vector", plus_card)
	in_card_2.c_named("direction", code_card)
	in_card_3.c_named("body", code_card_2)
	plus_card.c(store_card)
	pull_only_card.c_named("right_vetor", plus_card)
	store_card.c(vector_2_card)
	store_card_2.c(vector_2_card)
	store_card_3.c(bool_card)
	store_card_4.c(bool_card)
	vector_2_card.c(pull_only_card)
	vector_2_card.c_named("velocity", code_card)
	vector_2_card.c_named("velocity2", code_card_2)
