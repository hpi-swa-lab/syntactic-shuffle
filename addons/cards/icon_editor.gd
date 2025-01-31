extends Panel

signal save(texture: ImageTexture)

@export var texture: ImageTexture:
	get: return texture
	set(v):
		texture = v
		image = texture.image
		%Texture.texture = texture

var image: Image
var selected_color := Color.BLACK
var undo = []

func _ready() -> void:
	image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(image)
	%Texture.texture = texture
	%Texture.draw.connect(func():
		var size = %Texture.get_rect().size
		var color = Color(Color.BLACK, 0.1)
		%Texture.draw_rect(Rect2(Vector2.ZERO, size), color, false, 1)
		var step = %Texture.get_rect().size / float(image.get_size().x)
		for y in range(0, 16):
			%Texture.draw_line(Vector2(0, y * step.y), Vector2(size.x, y * step.y), color, 1)
		for x in range(0, 16):
			%Texture.draw_line(Vector2(x * step.x, 0), Vector2(x * step.x, size.y), color, 1))

func _on_color_changed(color: Color) -> void:
	selected_color = color

func _on_undo_pressed() -> void:
	var op = undo.pop_back()
	if not op: return
	if op is Image:
		image.copy_from(op)
	else:
		op.reverse()
		for pair in op: image.set_pixelv(pair[0], pair[1])
	texture.update(image)

func _on_clear_pressed() -> void:
	undo.push_back(image.duplicate())
	image.fill(Color.TRANSPARENT)
	texture.update(image)

func is_drawing():
	return _held

var _held = false
var erase = false
func _on_texture_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		_held = event.pressed
		erase = _held and event.button_index == MOUSE_BUTTON_RIGHT
		if _held:
			undo.push_back([])
			_paint(event)
	if event is InputEventMouseMotion and _held:
		_paint(event)

func _paint(event: InputEventMouse):
	var point = ((event.position - %Texture.position) / %Texture.get_rect().size * float(image.get_size().x)).floor()
	if point.x < 0 or point.y < 0 or point.x >= 15 or point.y >= 15: return
	undo[undo.size() - 1].push_back([point, image.get_pixelv(point)])
	image.set_pixelv(point, Color.TRANSPARENT if erase else selected_color)
	texture.update(image)

func _on_save_pressed() -> void:
	save.emit(texture)
	_on_cancel_pressed()

func _on_cancel_pressed() -> void:
	queue_free()
