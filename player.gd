extends CharacterBody2D

func _ready() -> void:
	$brain.visible = false

func take_damage(_damage: float):
	get_tree().change_scene_to_file("res://death_screen.tscn")
	queue_free()

func show_brain(_show: bool):
	$brain.visible = _show
