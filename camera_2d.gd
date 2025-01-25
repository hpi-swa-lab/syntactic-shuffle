extends Camera2D

@export var initial_camera_shake_strength = 30.0
@export var camera_shake_fade = 5.0
var camera_shake_strength = 0.0
var rng = RandomNumberGenerator.new()

@export var zoom_speed = 0.1
@export var pan = true

var held = false

func _ready():
	set_meta("cards_ignore", true)

func _zoom(factor: float) -> void:
	var delta = get_global_mouse_position() - global_position
	delta = delta - delta * zoom.x / (zoom.x + factor)
	zoom += Vector2(factor, factor)
	position += delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventPanGesture:
		_zoom(-1 * event.delta.y * zoom.x)
	if event is InputEventMouseButton:
		var factor = 0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: factor = -1
			MOUSE_BUTTON_WHEEL_UP: factor = 1
			_: factor = 0
		
		if factor != 0:
			factor *= event.factor * zoom_speed * zoom.x
			_zoom(factor)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and pan:
		held = event.is_pressed()
	if event is InputEventMouseMotion and held:
		position -= event.screen_relative / zoom

func _process(delta: float) -> void:
	if camera_shake_strength > 0.0:
		camera_shake_strength = lerpf(camera_shake_strength, 0.0, delta * camera_shake_fade)
		offset = get_random_camera_shake_offset()
		
func apply_camera_shake() -> void:
	camera_shake_strength = initial_camera_shake_strength
	
func get_random_camera_shake_offset() -> Vector2:
	return Vector2(rng.randf_range(- camera_shake_strength, camera_shake_strength), rng.randf_range(- camera_shake_strength, camera_shake_strength))
