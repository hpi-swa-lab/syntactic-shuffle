extends Area2D

@export var damage = 5

func _on_body_entered(node: Node2D) -> void:
	if node.is_in_group("health"):
		node.take_damage(damage)
	
	var knockback = (node.global_position - global_position).normalized() * 200
	
	if node is CharacterBody2D:
		node.velocity = knockback
		node.move_and_slide()
	elif node is PhysicsBody2D:
		node.move_and_collide(knockback * get_process_delta_time())
	else:
		node.position += knockback * get_process_delta_time()
