extends CharacterBody2D

func _process(delta: float) -> void:
	$RayCast2D.target_position = get_global_mouse_position() - global_position
