extends CharacterBody2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left_click"):
		$Pistol.shoot()

func take_damage(_damage: float):
	queue_free()
