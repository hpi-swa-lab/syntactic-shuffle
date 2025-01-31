extends TextureRect
class_name EditableCardIcon

@export var editable = false

func _open_editor():
	var editor = preload("res://addons/cards/icon_editor.tscn").instantiate()
	get_parent().add_child(editor)
	editor.global_position = global_position + get_rect().size / 2 - editor.get_rect().size / 2
	
	var path = texture.resource_path
	editor.texture = ImageTexture.create_from_image(texture.get_image())
	
	editor.save.connect(func(texture):
		editor.texture.get_image().save_png(path)
		editor.texture.take_over_path(path)
		self.texture = texture)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and editable and event.button_index == MOUSE_BUTTON_LEFT:
		_open_editor()
