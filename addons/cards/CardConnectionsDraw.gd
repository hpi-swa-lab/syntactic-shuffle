extends Node2D
class_name CardConnectionsDraw

var card: Card
var arrows_offset = 0.0

func _ready():
	name = "ConnectionDraw"
	z_index = 1

func _draw():
	if not card.show_cards() or card.disable: return
	for slot in card.slots:
		slot.draw(self)

func check_redraw(delta):
	if should_redraw(): queue_redraw()
	if card.dragging:
		arrows_offset += delta

var last_deps = null
func should_redraw():
	if card.disable: return false

	var deps = []
	for s in card.slots: s.get_draw_dependencies(deps)
	
	var comp_deps = last_deps
	last_deps = deps
	if comp_deps == null or card.dragging or comp_deps.size() != deps.size(): return true
	for i in range(deps.size()):
		if comp_deps[i] != deps[i]:
			return true
	return false

func draw_connection(from, to, inverted):
	if not to: return
	var target = to.global_position
	var distance = target.distance_to(from.global_position)
	var angle = from.global_position.angle_to_point(target) - from.get_global_transform().get_rotation()
	draw_set_transform(Vector2.ZERO, angle - PI / 2)
	const SIZE = 3
	const GAP = SIZE * 2.2
	
	var offset = arrows_offset * GAP
	offset = offset - int(offset)
	for i in range(0, distance / GAP):
		draw_arrow(Vector2(0, (i + offset) * GAP), SIZE, inverted, to)

func draw_arrow(pos, size, inverted, flash_key):
	draw_polyline(
		[pos + Vector2(-size, 0), pos + Vector2(0, -size if inverted else size), pos + Vector2(size, 0)],
		Color(Color.WHITE.lerp(Color.RED, _tween_values.get(flash_key, 0.0)), 1.0 if false else 0.5),
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
	var t = card.connection_draw_node.create_tween()
	_running_tweens[them] = t
	if current == null:
		t.tween_method(flash_line.bind(them), 0.0, 1.0, 0.2)
	t.tween_method(flash_line.bind(them), 1.0, 0.0, 0.2)

func flash_line(value: float, them):
	_tween_values[them] = value
	queue_redraw()
