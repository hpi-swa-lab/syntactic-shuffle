extends CharacterBody2D

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("ui_left_click"):
		$Pistol.shoot()

func take_damage(_damage: float):
	queue_free()
