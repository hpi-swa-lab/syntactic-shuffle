@tool
extends Card
class_name GameCard

func v():
	title("Game")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGdJREFUOI29k1EKwCAMQ5ux+1/57asgxc6IYwFBahNCWgXECa4j9o6ApKlVS6AjLwUkIQlAbU8X4or46sAlR0TcDrlmML5bIQLKUwW396C6+36RAOX4ZoRab8c4Nqdo3m0BB/99pg4P42k+F9T1hGUAAAAASUVORK5CYII=")
	container_size(Vector2(380.0, 64.0))

func s():
	var always_card = AlwaysCard.new()
	always_card.position = Vector2(677.0099, 1212.294)
	
	var axis_controls_card = AxisControlsCard.new()
	axis_controls_card.position = Vector2(602.1141, 469.6731)
	
	var axis_controls_card_2 = AxisControlsCard.new()
	axis_controls_card_2.position = Vector2(2097.97, 797.0679)
	
	var clock_card = ClockCard.new()
	clock_card.position = Vector2(-1198.083, 1247.965)
	clock_card.get_cell("seconds").data = 1.0
	
	var move_card = MoveCard.new()
	move_card.position = Vector2(-69.23253, 313.6645)
	
	var move_card_2 = MoveCard.new()
	move_card_2.position = Vector2(1756.841, 39.89466)
	
	var random_axis_card = RandomAxisCard.new()
	random_axis_card.position = Vector2(353.044, 961.3184)
	
	var vector_2_card = Vector2Card.new()
	vector_2_card.position = Vector2(-1207.379, 745.4684)
	vector_2_card.get_cell("vector").data = Vector2(1.0, 0.0)
	
	var wrap_command_card = WrapCommandCard.new()
	wrap_command_card.position = Vector2(-814.2891, 634.0615)
	wrap_command_card.get_cell("command").data = "direction"
	
	var block = load("res://game/block.tscn").instantiate()
	block.position = Vector2(-168.578, 1387.091)
	block.name = "block"
	scene_object(block)
	
	var tree = load("res://game/tree.tscn").instantiate()
	tree.position = Vector2(-175.0461, 654.3334)
	tree.name = "tree"
	scene_object(tree)
	
	always_card.c(random_axis_card)
	axis_controls_card.c(move_card)
	clock_card.c(vector_2_card)
	Card.ensure_card(tree).c(move_card)
	vector_2_card.c(wrap_command_card)
