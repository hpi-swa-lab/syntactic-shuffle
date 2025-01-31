extends TextureRect
class_name EditableCardIcon

@export var editable = false

var editor

func _ready():
	pass

func _open_editor():
	editor = preload("res://addons/cards/icon_editor.tscn").instantiate()
	get_parent().add_child(editor)
	editor.global_position = global_position + get_rect().size / 2 - editor.get_rect().size / 2
	
	var path = texture.resource_path
	editor.texture = ImageTexture.create_from_image(texture.get_image())
	
	editor.mouse_exited.connect(func():
		if not editor.is_drawing():
			editor.texture.get_image().save_png(path)
			editor.texture.take_over_path(path)
			texture = editor.texture
			editor.queue_free()
			editor = null)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and editable and event.button_index == MOUSE_BUTTON_LEFT:
		_open_editor()
