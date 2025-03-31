@tool
extends Card
class_name TreeSceneCard

func v():
	title("TreeScene")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGJJREFUOI1j/P//PwM2kPtcEENisuR7RnQxRnQDsGnEZxALsZpwASZyNCFbSJYBGC7AFjgkGUCJIfhjwf8vxPBTn3AazoIuAHNJrhkfUTFDnUAchgYQG4BEuwCfgRjpgFQAADm6KMGWwngSAAAAAElFTkSuQmCC")
	container_size(Vector2(401.0, 64.0))

func s():
	var out_card = OutCard.new(false)
	out_card.position = Vector2(544.2004, 19.23638)
	
	var tree = load("res://game/tree.tscn").instantiate()
	tree.position = Vector2(0.0, 0.0)
	tree.name = "tree"
	scene_object(tree)
	
	Card.ensure_card(tree).c(out_card)
