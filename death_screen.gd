extends Node2D

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	Globals.play_sound(preload("res://resources/sounds/Failure.wav"))
	
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://game.tscn")
