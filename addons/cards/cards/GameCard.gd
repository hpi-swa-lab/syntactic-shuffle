@tool
extends Card
class_name GameCard

func v():
	title("Game")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGdJREFUOI29k1EKwCAMQ5ux+1/57asgxc6IYwFBahNCWgXECa4j9o6ApKlVS6AjLwUkIQlAbU8X4or46sAlR0TcDrlmML5bIQLKUwW396C6+36RAOX4ZoRab8c4Nqdo3m0BB/99pg4P42k+F9T1hGUAAAAASUVORK5CYII=")
	container_size(Vector2(380.0, 64.0))

func s():
	var tree_scene_card = TreeSceneCard.new()
	tree_scene_card.position = Vector2(336.0899, 665.4766)
	
	var move_card = MoveCard.new()
	move_card.position = Vector2(1436.806, 84.7737)
	
	var axis_controls_card = AxisControlsCard.new()
	axis_controls_card.position = Vector2(1067.315, -283.8887)
	
	var clock_card = ClockCard.new()
	clock_card.position = Vector2(506.0218, -522.2972)
	clock_card.get_cell("seconds").data = 1.0
	
	var spawn_card = SpawnCard.new()
	spawn_card.position = Vector2(752.2662, 530.6744)
	
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(1152.266, 530.6744)
	
	tree_scene_card.c(spawn_card)
	axis_controls_card.c(move_card)
	spawn_card.c(remember_card)
	remember_card.c(move_card)
