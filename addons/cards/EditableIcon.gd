extends TextureRect

var editor: Control
var entered = false

func _ready() -> void:
	get_viewport().get_camera_2d().zoom_changed.connect(func(zoom):
		if editor and editor.get_viewport().get_camera_2d().zoom.x < 20:
			leave_editor_mode()
		elif not editor and get_viewport().get_camera_2d().zoom.x > 20 and entered:
			enter_edit_mode())
	mouse_entered.connect(func ():
		entered = true
		if get_viewport().get_camera_2d().zoom.x > 20:
			enter_edit_mode())
	mouse_exited.connect(func ():
		entered = false)

func enter_edit_mode():
	if editor: return
	
	editor = preload("res://addons/cards/icon_editor.tscn").instantiate()
	editor.texture = texture
	
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(editor)
	
	editor.get_parent().set_size(Vector2.ZERO)
	editor.set_size(Vector2.ZERO)

func leave_editor_mode():
	if editor:
		var parent = editor.get_parent()
		texture = editor.texture
		parent.remove_child(editor)
		parent.add_child(self)
		editor.queue_free()
		editor = null
