@tool
extends CardBoundary
class_name Trash

func card_dropped(card: Card):
	card.queue_free()

func _ready() -> void:
	card_scale = 0.01
	
	var icon = Sprite2D.new()
	icon.texture = preload("res://addons/cards/icons/delete.png")
	icon.scale = Vector2(5, 5)
	
	main_collision.shape.size = Vector2(80, 80)
	
	add_child(icon, false, Node.INTERNAL_MODE_FRONT)
