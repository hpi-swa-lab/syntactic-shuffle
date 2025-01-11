extends Node2D

signal spots(object: Object)

func _physics_process(delta: float) -> void:
	var hit = {}
	for offset in range(-30, 30):
		$RayCast2D.rotation_degrees = 180 + offset
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			if not hit.get(collider):
				hit[collider] = true
				spots.emit(collider)
