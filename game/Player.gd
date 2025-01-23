@tool
extends CharacterBody2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	$RayCast2D.target_position = get_global_mouse_position() - global_position

func can_grab():
	return true#not $RayCast2D.is_colliding()


func _on_kill_area_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()
