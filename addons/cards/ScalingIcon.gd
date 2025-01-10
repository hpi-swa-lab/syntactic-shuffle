@tool
extends TextureRect
class_name ScalingIcon

var _data = ""
@export_file("*.svg") var path: String = "":
	get: return path
	set(value):
		path = value
		var file = FileAccess.open(path, FileAccess.READ)
		_data = file.get_as_text()
		_update_texture()

var _current_zoom = 1
func _process(_dt):
	var zoom = get_viewport_transform().get_scale().x
	zoom *= get_screen_transform().get_scale().x
	# FIXME hard-coded SVG viewport width
	zoom *= get_rect().size.x / 16
	if _current_zoom != zoom:
		_current_zoom = zoom
		_update_texture()

func _update_texture():
	if _data.length() == 0: return
	
	var image = Image.new()
	image.load_svg_from_string(_data, _current_zoom)
	image.fix_alpha_edges()
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	
	self.texture = texture
