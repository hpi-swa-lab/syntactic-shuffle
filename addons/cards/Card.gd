@tool
extends Node2D
class_name Card

const SHOW_IN_GAME = true
const DEFAULT_SCALE = Vector2(0.15, 0.15)
const MAX_CONNECTION_DISTANCE = 150

@export var disable = false:
	set(v):
		disable = v
		if connection_draw_node: connection_draw_node.queue_redraw()
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

func invoke_output(args):
	get_output_slot().invoke(self, args)

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
		if not dragging:
			CardBoundary.get_card_boundary(self).card_dropped(self)
		connection_draw_node.queue_redraw()
	get:
		return dragging

func maybe_add_to_hand():
	var pos = PhysicsPointQueryParameters2D.new()
	pos.position = global_position
	pos.collide_with_areas = true
	pos.collide_with_bodies = true
	for h in get_tree().get_nodes_in_group("hand"):
		if h.includes_screen_point(get_viewport().canvas_transform * global_position):
			h.add_card(self)

func current_hand():
	return G.closest_parent_that(self, func(node): return node.is_in_group(&"hand"))

func is_in_hand():
	return current_hand() != null

enum Type {
	Trigger,
	Effect,
	Store
}

static func show_cards():
	return not Engine.is_editor_hint() or SHOW_IN_GAME

func can_connect_to(obj: Node):
	return obj.owner == self.owner and not obj is Camera2D

var connection_draw_node: Node2D

func _ready() -> void:
	if not show_cards(): return
	
	# we draw connections in a separate node whose z-index is below all content,
	# such that the connections appear under the cards
	connection_draw_node = Node2D.new()
	connection_draw_node.name = "ConnectionDraw"
	connection_draw_node.z_index = 1
	connection_draw_node.draw.connect(draw_connections)
	add_child(connection_draw_node)
	
	visual = preload("res://addons/cards/CardVisual.tscn").instantiate()
	visual.scale = DEFAULT_SCALE
	visual.dragging.connect(func (d): set_selected(d))
	add_child(visual)

func setup(name: String, description: String, type: Type, slots: Array[Slot], extra_ui: Control = null):
	if not show_cards(): return
	var type_icon
	match type:
		Type.Trigger: type_icon = "Signals.svg"
		Type.Effect: type_icon = "PreviewSun.svg"
		Type.Store: type_icon = "CylinderMesh.svg"
	
	visual.setup(name, description, get_icon_name(), type_icon, extra_ui)
	
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
	if not show_cards(): return
	if dragging: CardBoundary.card_moved(self)
	
	if disable: return
	
	if dragging:
		for slot in slots:
			slot.check_disconnect(self, self)
			var c = G.closest_node(self, func(n, d): return slot.can_connect_to(n))
			if c:
				var dist = c.global_position.distance_to(global_position)
				if dist > MAX_CONNECTION_DISTANCE and c is Card:
					var o = c.get_output_slot()
					if o: o.check_disconnect(self, c)
					var i = c.get_input_slot()
					if i: i.check_disconnect(self, c)
				elif dist < MAX_CONNECTION_DISTANCE:
					slot.connect_to(self, c)
			slot.arrows_offset += delta
	
	if should_redraw() and not disable:
		connection_draw_node.queue_redraw()

var arrows_offset = 0
func draw_connections() -> void:
	if not show_cards() or disable: return
	for slot in slots:
		slot.draw(self, connection_draw_node)

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

func get_extent() -> Vector2:
	return visual.get_extent()
