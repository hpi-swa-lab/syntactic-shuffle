extends Node2D
class_name Game

@export var levels: Array[PackedScene]
var level: Node2D
var level_index = -1

func _ready() -> void:
	next_level()

func next_level():
	if level_index == len(levels) - 1:
		end_screen()
		return
	level_index += 1
	remove_child(level)
	level = levels[level_index].instantiate()
	add_child(level)
	%NextLevelButton.hide()

func end_screen():
	pass

func won():
	%NextLevelButton.show()
