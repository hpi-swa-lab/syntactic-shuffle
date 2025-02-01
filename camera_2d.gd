extends Camera2D

@export var zoom_speed = 0.1
@export var pan = true

var held = false
var selecting = false
var selection = {}

func clear_selection():
	for card in selection: card.visual.on_deselected()
	selection.clear()

func set_as_selection(obj: Node):
	clear_selection()
	add_to_selection(obj)

func is_selected(obj: Node):
	return selection.has(obj)

func add_to_selection(obj: Node):
	selection[obj] = true
	obj.visual.on_selected()

func consider_selection(obj: Node):
	if selecting: add_to_selection(obj)

func move_selected(delta: Vector2):
	for card in selection: card.position += delta

func _ready(): Card.set_ignore_object(self)

func _zoom(factor: float) -> void:
	var delta = get_global_mouse_position() - global_position
	delta = delta - delta * zoom.x / (zoom.x + factor)
	zoom += Vector2(factor, factor)
	position += delta

func _input(event: InputEvent) -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selecting = event.is_pressed()
		if selecting: clear_selection()
