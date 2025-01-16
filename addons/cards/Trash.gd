@tool
extends CardBoundary
class_name Trash

func card_dropped(card: Card):
	Card.editor_sync("cards:delete", [Card.get_id(card)])
	card.queue_free()

func _ready() -> void:
	super._ready()
	
	card_scale = 0.01
	
	var icon = Sprite2D.new()
	icon.texture = preload("res://addons/cards/icons/delete.png")
	icon.scale = Vector2(5, 5)
	
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(80, 80)
	
	add_child(icon, false, Node.INTERNAL_MODE_FRONT)
	add_child(collision, false, Node.INTERNAL_MODE_FRONT)
