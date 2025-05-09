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
			var node = card.lookup_card(p)
			if node:
				draw_connection(self, node, true, light_background)
				draw_label_to(node, name, light_background)

func check_redraw(delta):
	if should_redraw():
		queue_redraw()
		reposition_feedback()

func reposition_feedback():
	if not card: return
	
	var size = card.visual.get_rect().size + 65 * global_scale
	var top_left = global_position - size / 2
	var box = AABB(Vector3(top_left.x, top_left.y, 0), Vector3(size.x, size.y, 0))
	
	for to in card._feedback:
		if to == null: continue
		var f = card._feedback[to]
		if not f.get_parent(): add_child(f)
		var dir = global_position - to.global_position
		var i = box.intersects_ray(Vector3(to.global_position.x, to.global_position.y, 0.0), Vector3(dir.x, dir.y, 0.0))
		var intersection = Vector2(i.x, i.y)
		
		var feedback_rect = get_global_transform() * f.get_rect()
		f.global_position = intersection - feedback_rect.size / 2
	if card._feedback.has(null):
		var f = card._feedback[null]
		if not f.get_parent(): add_child(f)
		var feedback_rect = get_global_transform() * f.get_rect()
		f.global_position = global_position + Vector2(size.x / 2, 0) - feedback_rect.size / 2

var last_deps = null
func should_redraw():
	if card.disable: return false
	
	var dragging = card.dragging
	var deps = []
	for to in card.get_incoming():
		deps.push_back(to.get_card_global_position())
		deps.push_back(to.global_scale)
		if to.visual: deps.push_back(to.visual.hovered)
		dragging = dragging or object_is_dragging(to)
	for node in card.get_named_incoming():
		deps.push_back(node.get_card_global_position())
		deps.push_back(node.global_scale)
		if node.visual: deps.push_back(node.visual.hovered)
		dragging = dragging or object_is_dragging(node)
	if not deps.is_empty():
		deps.push_back(card.get_card_global_position())
		deps.push_back(card.global_scale)
		if card.visual: deps.push_back(card.visual.hovered)
	
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

func draw_label_to(obj: Card, label: String, light_background: bool):
	var font = ThemeDB.fallback_font
	var angle = global_position.angle_to_point(obj.get_card_global_position())
	var flip = abs(angle) > PI / 2
	const FONT_SIZE = 10
	const OFFSET = 32
	
	var a = Transform2D(angle + PI if flip else angle, Vector2.ZERO) * Transform2D(0.0, Vector2(-OFFSET - font.get_multiline_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE).x if flip else OFFSET, -4))
	draw_set_transform_matrix(a.scaled(Vector2.ONE / global_scale))
	draw_string(font, Vector2(0, 0), label, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, Color(LIGHT_BACKGROUND_BASE if light_background else Color.WHITE, 1))

func _is_connection_valid(to: CardConnectionsDraw, from: Card):
	for out in from.cards:
		if out is OutCard:
			for input in to.card.cards:
				if input is InCard:
					for their_signature in out.output_signatures:
						for my_signature in input.input_signatures:
							if their_signature.compatible_with(my_signature):
								return true
	return false

func draw_connection(from: CardConnectionsDraw, to: Card, inverted, light_background: bool):
	if not to: return
	var fade_out = from.card.locked.has(to) and not from.card.visual.hovered and not to.visual.hovered
	var target = to.get_card_global_position()
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
	var base = Color(orig, 0.5).lerp(Color.GREEN, remap(stretch, 0.4, 0, 1, 0)) if Card.always_reconnect() else Color(orig, 1)
	# For debugging purposes:
	# if not _is_connection_valid(from, to): base = Color.PINK
	var color = base.lerp(Color.RED, _tween_values.get(to, 0.0))
	for i in range(0, distance / GAP):
		var progress = i / (distance / GAP)
		var pos = Vector2(0, (i + offset) * GAP)
		var base_opacity = max((150 - pos.y) / 150.0, remap(pos.y, distance - 150, distance, 0, 1), 0) if fade_out else 1
		var points = [pos + Vector2(-SIZE, 0), pos + Vector2(0, -SIZE if inverted else SIZE), pos + Vector2(SIZE, 0)]
		draw_polyline(points, Color(color, color.a * base_opacity), SIZE * 0.25, true)

var _tween_values = {}
var _running_tweens = {}
var flash_value = 0.0
func on_activated(them):
	var current = _running_tweens.get(them)
	if current != null and not current.is_running(): current = null
	if current and current.get_total_elapsed_time() < 0.1: return
	if current != null: current.kill()
	var t = create_tween()
	_running_tweens[them] = t
	var from = 0.6 if current and current.get_total_elapsed_time() < 0.4 else _tween_values.get(them, 0.0)
	t.tween_method(flash_line.bind(them), from, 1.0, 0.15)
	t.tween_method(flash_line.bind(them), 1.0, 0.0, 0.2).set_delay(0.15)

func flash_line(value: float, them):
	_tween_values[them] = value
	queue_redraw()
