extends Node2D

@export var radius = 512
@export var degrees = 30

func _draw() -> void:
	draw_rect(Rect2(-radius, -radius, 2 * radius, 2 * radius), Color.BLACK)
	var points = [Vector2.ZERO]
	for degree in range(degrees * -0.5, degrees * 0.5):
		points.append(Vector2.from_angle(deg_to_rad(degree)) * radius)
	draw_colored_polygon(PackedVector2Array(points), Color.WHITE)
