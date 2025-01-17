@tool
extends CardBoundary
class_name CardGroup

var background: Placeholder

func _ready():
	super._ready()
	
	background = Placeholder.new()
	add_child(background, false, Node.INTERNAL_MODE_FRONT)
	background.placeholder_size = Vector2(300, 300)
	background.color = Color.BLACK
	
	pause_on_enter = true

func instantiate():
	var scene = duplicate(DUPLICATE_USE_INSTANTIATION | DUPLICATE_SCRIPTS | DUPLICATE_GROUPS | DUPLICATE_SIGNALS)
	scene.get_child(0, true).queue_free()
	
	var root = Node2D.new()
	scene.replace_by(root)
	scene.free()
	
	return root
