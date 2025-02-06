extends Node2D
class_name CardConnectionsDraw

const LIGHT_BACKGROUND_BASE = Color(0.2, 0.2, 0.2)

var card: Card

var dragging:
	get: return card.dragging

func _ready():
	name = "ConnectionDraw"
	z_index = 1

func _draw():
	if not card or card.disable: return
	var light_background = card.get_card_boundary().light_background
	for to in card.get_incoming():
		draw_connection(self, to, true, light_background)
	var named = card.named_incoming
	for name in named:
		for p in named[name]:
			var node = card.get_node_or_null(p)
			if node:
				draw_connection(self, node, true, light_background)
				draw_label_to(node, name, light_background)

var _feedback = {}
func show_feedback_for(to: Node, args: Array):
	if args.is_empty() or not card: return
	if not _feedback.has(to):
		_feedback[to] = preload("res://addons/cards/feedback_card.tscn").instantiate()
		_feedback[to].position = Vector2(100, 100)
		add_child(_feedback[to])
	_feedback[to].report_object(args[0])
	reposition_feedback()
func outgoing_connected(obj: Node):
	if _feedback.has(null): _delete_feedback_for(null)
func incoming_disconnected(obj: Node):
	if _feedback.has(null): _delete_feedback_for(null)
func outgoing_disconnected(obj: Node):
	for to in _feedback.duplicate():
		if to == obj: _delete_feedback_for(to)
func _delete_feedback_for(to):
	assert(_feedback[to].is_inside_tree())
	remove_child(_feedback[to])
	_feedback[to].queue_free()
	_feedback.erase(to)

func check_redraw(delta):
	if should_redraw():
		queue_redraw()
		reposition_feedback()

func reposition_feedback():
	if not card: return
	
	var size = card.visual.get_rect().size + 65 * global_scale
	var top_left = global_position - size / 2
	var box = AABB(Vector3(top_left.x, top_left.y, 0), Vector3(size.x, size.y, 0))
	
	for to in _feedback:
		if to == null: continue
		var dir = global_position - to.global_position
		var i = box.intersects_ray(Vector3(to.global_position.x, to.global_position.y, 0.0), Vector3(dir.x, dir.y, 0.0))
		var intersection = Vector2(i.x, i.y)
		
		var feedback_rect = get_global_transform() * _feedback[to].get_rect()
		_feedback[to].global_position = intersection - feedback_rect.size / 2
	if _feedback.has(null):
		var feedback_rect = get_global_transform() * _feedback[null].get_rect()
		_feedback[null].global_position = global_position + Vector2(size.x / 2, 0) - feedback_rect.size / 2

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

func draw_label_to(obj: Node2D, label: String, light_background: bool):
	var font = ThemeDB.fallback_font
	var angle = global_position.angle_to_point(obj.global_position)
	var flip = abs(angle) > PI / 2
	const FONT_SIZE = 10
	const OFFSET = 32
	
	var a = Transform2D(angle + PI if flip else angle, Vector2.ZERO) * Transform2D(0.0, Vector2(-OFFSET - font.get_multiline_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE).x if flip else OFFSET, -4))
	draw_set_transform_matrix(a.scaled(Vector2.ONE / global_scale))
	draw_string(font, Vector2(0, 0), label, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, Color(LIGHT_BACKGROUND_BASE if light_background else Color.WHITE, 1))

func draw_connection(from, to, inverted, light_background: bool):
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
	offset = 1 - (offset - int(offset))
	var stretch = 1 - distance / Card.MAX_CONNECTION_DISTANCE
	
	var orig = LIGHT_BACKGROUND_BASE if light_background else Color.WHITE
	var base = Color(orig, 0.5).lerp(Color.GREEN, remap(stretch, 0.4, 0, 1, 0)) if Card.always_reconnect() else Color(orig, 3)
	var color = base.lerp(Color.RED, _tween_values.get(to, 0.0))
	for i in range(0, distance / GAP):
		var pos = Vector2(0, (i + offset) * GAP)
		var points = [pos + Vector2(-SIZE, 0), pos + Vector2(0, -SIZE if inverted else SIZE), pos + Vector2(SIZE, 0)]
		draw_polyline(points, color, SIZE * 0.25, true)

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
