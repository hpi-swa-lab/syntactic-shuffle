@tool
extends Sprite2D
class_name CardProxy

@export var proxy_target: Node:
	get:
		return proxy_target
	set(v):
		proxy_target = v
		for group in get_groups():
			remove_from_group(group)
		for group in v.get_groups():
			add_to_group(group)

func _ready() -> void:
	texture = preload("res://addons/cards/icons/brain.png")
