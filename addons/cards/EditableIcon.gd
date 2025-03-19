extends TextureRect

var editor: Control
var entered = false

func _ready() -> void:
	get_viewport().get_camera_2d().zoom_changed.connect(func(zoom):
		if editor and editor.get_viewport().get_camera_2d().zoom.x < 20:
			leave_edit_mode()
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
	
	entered = false
	editor = preload("res://addons/cards/icon_editor.tscn").instantiate()
	editor.texture = texture
	
	visible = false
	get_parent().add_child(editor)

func leave_edit_mode():
	if editor:
		texture = editor.texture
		editor.queue_free()
		editor = null
		visible = true
