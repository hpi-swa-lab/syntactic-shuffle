extends Node2D
class_name CardConnectionsDraw

var card: Card

var dragging:
	get: return card.dragging

func _ready():
	name = "ConnectionDraw"
	z_index = 1

func _draw():
	if not card or card.disable: return
	for to in card.get_incoming():
		draw_connection(self, to, true)
	var named = card.named_incoming
	for name in named:
		for p in named[name]:
			var node = card.get_node_or_null(p)
			if node:
				draw_connection(self, node, true)
				draw_label_to(node, name)

func check_redraw(delta):
	if should_redraw(): queue_redraw()

var last_deps = null
func should_redraw():
	if card.disable: return false
	
	var dragging = card.dragging
	var deps = []
	for to in card.get_incoming():
		deps.push_back(to.global_position)
		dragging = dragging or object_is_dragging(to)
	for node in card.get_named_incoming():
		deps.push_back(node.global_position)
		dragging = dragging or object_is_dragging(node)
	if not deps.is_empty(): deps.push_back(global_position)
	
	var comp_deps = last_deps
	last_deps = deps
	if comp_deps == null or dragging or comp_deps.size() != deps.size(): return true
	for i in range(deps.size()):
		if comp_deps[i] != deps[i]:
			return true
	return false

func get_draw_offset(from, to):
	if object_is_dragging(from) or object_is_dragging(to):
		return Time.get_ticks_msec() / 100.0
	return 0

static func object_is_dragging(object):
	return "dragging" in object and object.dragging

func draw_label_to(obj: Node2D, label: String):
	return
	var font = ThemeDB.fallback_font
	var angle = global_position.angle_to_point(obj.global_position)
	var flip = abs(angle) > PI / 2
	const FONT_SIZE = 10
	const OFFSET = 32
	
	var a = Transform2D(angle + PI if flip else angle, Vector2.ZERO) * Transform2D(0.0, Vector2(-OFFSET - font.get_multiline_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE).x if flip else OFFSET, -4))
	draw_set_transform_matrix(a.scaled(Vector2.ONE / global_scale))
	draw_string(font, Vector2(0, 0), label, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, Color(Color.WHITE, 0.7))

func draw_connection(from, to, inverted):
	if not to: return
	var t = _tween_values.get(to, 0.0)
	if t == 0.0:
		draw_connection2(from, to, inverted)
		return
	var target = to.global_position
	var distance = target.distance_to(from.global_position)
	# FIXME save guard -- if this happens, we have a problem anyways
	# that needs to be solved differently
	distance = min(distance, 1000)
	
	var angle = from.global_position.angle_to_point(target) - from.get_global_transform().get_rotation()
	
	const SIZE = 3
	const GAP = SIZE * 5
	
	var offset = -get_draw_offset(from, to) * GAP
	offset = offset - int(offset)
	var stretch = 1 - distance / Card.MAX_CONNECTION_DISTANCE
	for i in range(0, distance / GAP):
		#draw_arrow(Vector2(0, (i + offset) * GAP), SIZE, inverted, to, stretch)
		var alpha = lerp(0.4, 1.0, t)
		var transform = (Transform2D(angle - PI / 2, Vector2.ONE / global_scale, 0.0, Vector2.ZERO) * Transform2D(0, Vector2(0, (i + offset) * GAP))
			* Transform2D(0, Vector2(32 / -2, 32 / -2)) * Transform2D(0, Vector2(16.0 / 512, 16.0 / 512), 0, Vector2.ZERO) * Transform2D(0, Vector2(512 / 2, 512 / 2)))
		draw_set_transform_matrix(transform)
		var color = Color.WHITE.lerp(Color.DARK_ORANGE, t)
		draw_texture(preload("res://game/assets/a-rabbits-favorite-food-yummy-yummy.png"), Vector2(0, 0), Color(color, alpha))
		#draw_texture(preload("res://game/assets/carrot.png"), Vector2(0, 0), Color(Color.WHITE, alpha))

func draw_connection2(from, to, inverted):
	if not to: return
	var target = to.global_position
	var distance = target.distance_to(from.global_position)
	# FIXME save guard -- if this happens, we have a problem anyways
	# that needs to be solved differently
	distance = min(distance, 1000)
	
	var angle = from.global_position.angle_to_point(target) - from.get_global_transform().get_rotation()
	draw_set_transform(Vector2.ZERO, angle - PI / 2, Vector2.ONE / global_scale)
	const SIZE = 3
	const GAP = SIZE * 2.2
	
	var offset = get_draw_offset(from, to) * GAP
	offset = offset - int(offset)
	var stretch = 1 - distance / Card.MAX_CONNECTION_DISTANCE
	for i in range(0, distance / GAP):
		draw_arrow(Vector2(0, (i + offset) * GAP), SIZE, inverted, to, stretch)

func draw_arrow(pos, size, inverted, flash_key, stretch):
	#var base = Color(Color.WHITE, 0.2).lerp(Color.WHITE, remap(stretch, 0.4, 0, 1, 0)) if Card.always_reconned() else Color(Color.WHITE, 1)
	var base = Color(Color.WHITE, 0.9)
	draw_polyline(
		[pos + Vector2(-size, 0), pos + Vector2(0, -size if inverted else size), pos + Vector2(size, 0)],
		base.lerp(Color.DARK_ORANGE, _tween_values.get(flash_key, 0.0)),
		size / 2,
		true)

var _tween_values = {}
var _running_tweens = {}
var flash_value = 0.0
func on_activated(them):
	var current = _running_tweens.get(them)
	if current != null and not current.is_running(): current = null
	if current != null:
		if current.get_total_elapsed_time() < 0.1: return
		else: current.kill()
	var t = create_tween()
	_running_tweens[them] = t
	if current == null:
		t.tween_method(flash_line.bind(them), 0.0, 1.0, 0.2)
	t.tween_method(flash_line.bind(them), 1.0, 0.0, 0.2)

func flash_line(value: float, them):
	_tween_values[them] = value
	queue_redraw()
