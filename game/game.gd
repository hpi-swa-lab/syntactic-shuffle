extends Node2D
class_name Game

@export var levels: Array[PackedScene]
var level: Node2D
@export var level_index = 0

func _ready() -> void:
	next_level()

func next_level():
	if level_index == len(levels):
		end_screen()
		return
	if level: remove_child(level)
	level = levels[level_index].instantiate()
	add_child(level)
	%NextLevelButton.hide()
	level_index += 1

func end_screen():
	pass

func won():
	%NextLevelButton.show()
