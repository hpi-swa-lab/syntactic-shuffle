@tool
extends Node2D
class_name Card

const SHOW_IN_GAME = true
const DEFAULT_SCALE = Vector2(0.15, 0.15)
const MAX_CONNECTION_DISTANCE = 300

@export var disable = false:
	set(v):
		disable = v
		queue_redraw()
	get:
		return disable

func on_invoke_input(callable: Callable):
	get_input_slot().invoke_called.connect(func (args):
		callable.callv(args))

func get_object_input():
	return get_object_input_slot().get_object(self)

func get_input_slot() -> InputSlot:
	for s in slots:
		if s is InputSlot: return s
	return null

func get_object_input_slot() -> ObjectInputSlot:
	for s in slots:
		if s is ObjectInputSlot: return s
	return null

func get_object_output_slot() -> ObjectOutputSlot:
	for s in slots:
		if s is ObjectOutputSlot: return s
	return null

func get_output_slot() -> OutputSlot:
	for s in slots:
		if s is OutputSlot: return s
	return null

@export var slots: Array[Slot]
var visual: CardVisual
var dragging:
	set(v):
		if v == dragging: return
		dragging = v
		if disable and dragging:
			transition_from_hand()
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

func transition_from_hand():
	disable = false
	reparent(get_tree().current_scene)
	global_position = get_viewport().get_camera_2d().get_global_mouse_position()
	visual.get_node("CardControl").grab_focus.call_deferred()

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

func setup(name: String, description: String, type: Type, slots: Array[Slot]):
	if not show_cards(): return
	var type_icon
	match type:
		Type.Trigger: type_icon = "Signals"
		Type.Effect: type_icon = "PreviewSun"
		Type.Store: type_icon = "CylinderMesh"
	
	visual.setup(name, description, get_icon_name(), type_icon)
	
	# do not override deserialized slots if they exist
	if self.slots.is_empty():
		self.slots = slots
		assert(slots.filter(func (s): return s is InputSlot).size() <= 1)
		assert(slots.filter(func (s): return s is OutputSlot).size() <= 1)

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
		for slot in slots:
			slot.check_disconnect(self)
			var c = G.closest_node(self, func(n, d): return slot.can_connect_to(n))
			if c:
				var dist = c.global_position.distance_to(global_position)
				if dist > MAX_CONNECTION_DISTANCE and c is Card:
					var o = c.get_output_slot()
					if o: o.check_disconnect(c)
					var i = c.get_input_slot()
					if i: i.check_disconnect(c)
				elif dist < MAX_CONNECTION_DISTANCE:
					slot.connect_to(self, c)
			slot.arrows_offset += delta
	
	if should_redraw() and not disable:
		queue_redraw()

var arrows_offset = 0
func _draw() -> void:
	if not show_cards() or disable: return
	for slot in slots: slot.draw(self)

var last_deps = null
func should_redraw():
	var deps = []
	for s in slots: s.get_draw_dependencies(self, deps)
	
	var comp_deps = last_deps
	last_deps = deps
	if not comp_deps or dragging or comp_deps.size() != deps.size(): return true
	for i in range(deps.size()):
		if comp_deps[i] != deps[i]:
			return true
	return false
