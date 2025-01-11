@tool
extends TextureRect
class_name ScalingIcon

var _data = ""
@export_file("*.svg") var path: String = "":
	get: return path
	set(value):
		path = value
		if path == "":
			_data = null
		elif is_svg():
			var file = FileAccess.open(path, FileAccess.READ)
			_data = file.get_as_text()
		else:
			_data = load(path)
		_update_texture()

func is_svg() -> bool:
	return path.ends_with(".svg")

var _current_zoom = 1
func _process(_dt):
	var zoom = get_viewport_transform().get_scale().x
	zoom *= get_screen_transform().get_scale().x
	# FIXME hard-coded SVG viewport width
	zoom *= get_rect().size.x / 16
	zoom = min(zoom, 10)
	if _current_zoom != zoom:
		_current_zoom = zoom
		if is_svg():
			_update_texture()

func _update_texture():
	if _data == null: return
	
	var texture = ImageTexture.new()
	if is_svg():
		var image = Image.new()
		image.load_svg_from_string(_data, _current_zoom)
		image.fix_alpha_edges()
		texture.set_image(image)
	else:
		texture = _data
	
	self.texture = texture
