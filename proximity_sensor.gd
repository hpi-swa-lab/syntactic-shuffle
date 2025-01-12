extends Node2D

signal detected(object: Object)

func _on_fov_spots(object: Object) -> void:
	if object is Node2D and object.is_in_group("health"):
		detected.emit(object)
