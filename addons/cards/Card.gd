@tool
extends Node2D
class_name Card

const SHOW_IN_GAME = true
const DEFAULT_SCALE = Vector2(0.15, 0.15)

@export var disable = false:
	set(v):
		disable = v
		queue_redraw()
	get:
		return disable

var visual: CardVisual
var dragging:
	set(v):
		dragging = v
		queue_redraw()
	get:
		return dragging

@export var connected_node: NodePath = NodePath()

enum Type {
	Trigger,
	Effect,
	Store
}

static func show_cards():
	return not Engine.is_editor_hint() or SHOW_IN_GAME

func can_connect_to(obj: Node):
	return obj.owner == self.owner and not obj is Camera2D

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	print(event)

func _ready() -> void:
	if not show_cards(): return
	
	visual = preload("res://addons/cards/CardVisual.tscn").instantiate()
	visual.scale = DEFAULT_SCALE
	visual.dragging.connect(func (d): set_selected(d))
	add_child(visual)

func setup(name: String, description: String, type: Type):
	if not show_cards(): return
	var type_icon
	match type:
		Type.Trigger: type_icon = "Signals"
		Type.Effect: type_icon = "PreviewSun"
		Type.Store: type_icon = "CylinderMesh"
	
	visual.setup(name, description, get_icon_name(), type_icon)

func connected():
	return get_node_or_null(connected_node)

func trigger0():
	var node = connected()
	if node and node.has_method("invoke0"): node.invoke0()

func trigger1(arg):
	var node = get_node_or_null(connected_node)
	if node and node.has_method("invoke1"): node.invoke1(arg)

func set_selected(selected: bool):
	create_tween().tween_property(visual, "scale",
			DEFAULT_SCALE * 1.1 if selected else DEFAULT_SCALE,
			0.17 if selected else 0.13).from_current().set_trans(Tween.TRANS_EXPO)
	dragging = selected

func get_icon_name():
	if get_script():
		var name = get_script().resource_path.get_file().split('.')[0]
		return G.at("addon").cards[name]
	return null

func _forward_canvas_gui_input(event: InputEvent, undo_redo):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		arrows_offset = 0.0
	return false

func _process(delta: float) -> void:
	if not show_cards() or disable: return
	if dragging:
		connected_node = G.or_default(G.closest_node(self, func(n, d): return can_connect_to(n)), func(n): return get_path_to(n), NodePath())
		arrows_offset += delta
	
	if should_redraw() and not disable:
		queue_redraw()

var arrows_offset = 0
func _draw() -> void:
	if not show_cards() or disable: return
	
	var target_node = get_node_or_null(connected_node)
	if not target_node:
		return
	
	var target = target_node.global_position
	var distance = target.distance_to(global_position)
	var angle = global_position.angle_to_point(target) - get_global_transform().get_rotation()
	draw_set_transform(Vector2.ZERO, angle - PI / 2)
	const SIZE = 3
	const GAP = SIZE * 2.2
	
	var offset = arrows_offset * GAP
	offset = offset - int(offset)
	
	for i in range(0, distance / GAP):
		draw_arrow(Vector2(0, (i + offset) * GAP), SIZE)

var last_deps = null
func should_redraw():
	var deps = [
		G.or_default(get_node_or_null(connected_node), func(n): return n.global_position),
		global_position
	]
	var comp_deps = last_deps
	last_deps = deps
	if not comp_deps or dragging: return true
	for i in range(deps.size()):
		if comp_deps[i] != deps[i]:
			return true
	return false

func draw_arrow(pos, size = 10):
	draw_polyline(
		[pos + Vector2(-size, 0), pos + Vector2(0, size), pos + Vector2(size, 0)],
		Color(Color.GRAY, 1.0 if dragging else 0.3),
		size / 2,
		true)
