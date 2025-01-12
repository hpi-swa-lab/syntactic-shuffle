extends CharacterBody2D

func _ready() -> void:
	$brain.visible = false

func take_damage(_damage: float):
	queue_free()

func show_brain(_show: bool):
	$brain.visible = _show
