extends Camera2D

@export var zoom_speed = 0.05

var held = false

func _zoom(factor: float) -> void:
	zoom += Vector2(factor, factor)

func _input(event: InputEvent) -> void:
	if event is InputEventPanGesture:
		_zoom(-1 * event.delta.y * zoom.x)
	if event is InputEventMouseButton:
		var factor = 0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: factor = -1
			MOUSE_BUTTON_WHEEL_UP: factor = 1
			_: factor = 0
		factor *= event.factor * zoom_speed * zoom.x
		_zoom(factor)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		held = event.is_pressed()
	if event is InputEventMouseMotion and held:
		position -= event.screen_relative / zoom
