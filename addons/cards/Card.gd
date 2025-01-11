@tool
extends Node2D
class_name Card

const SHOW_IN_GAME = true
const DEFAULT_SCALE = Vector2(0.15, 0.15)
const MAX_CONNECTION_DISTANCE = 300

class Slot extends Resource:
	var num_args = 0
	var arrows_offset = 0.0
	func can_connect_to(object):
		return false
	func connect_to(from: Node, object: Node):
		pass
	func check_disconnect(card: Card):
		pass
	func draw(node):
		pass
	func get_draw_dependencies(card: Card, array: Array):
		pass
	func draw_connection(from, to, inverted = false):
		if not to: return
		var target = to.global_position
		var distance = target.distance_to(from.global_position)
		var angle = from.global_position.angle_to_point(target) - from.get_global_transform().get_rotation()
		from.draw_set_transform(Vector2.ZERO, angle - PI / 2)
		const SIZE = 3
		const GAP = SIZE * 2.2
		
		var offset = arrows_offset * GAP
		offset = offset - int(offset)
		# TODO inverted
		
		for i in range(0, distance / GAP):
			draw_arrow(from, Vector2(0, (i + offset) * GAP), SIZE)
	
	func draw_arrow(node, pos, size = 10):
		node.draw_polyline(
			[pos + Vector2(-size, 0), pos + Vector2(0, size), pos + Vector2(size, 0)],
			Color(Color.GRAY, 1.0 if true else 0.3),
			size / 2,
			true)

## Provide an object as input, for example Collision triggers need to know
## which object to listen to collisions for.
class ObjectInputSlot extends Slot:
	var on_connect
	var on_disconnect
	@export var object_path: NodePath
	func _init(on_connect = null, on_disconnect = null) -> void:
		self.on_connect = on_connect
		self.on_disconnect = on_disconnect
	func get_object(card: Card):
		return card.get_node_or_null(object_path)
	func can_connect_to(object):
		return not object is Card and object.get_parent() and object.get_parent().name == "main" and not object is Camera2D
	func connect_to(from: Node, object: Node):
		object_path = from.get_path_to(object)
	func check_disconnect(card: Card):
		var o = get_object(card)
		if o and o.global_position.distance_to(card.global_position) > MAX_CONNECTION_DISTANCE:
			object_path = NodePath()
	func draw(node):
		var object = node.get_node_or_null(object_path)
		if object: draw_connection(node, object, true)
	func get_draw_dependencies(card: Card, deps: Array):
		var object = card.get_node_or_null(object_path)
		if object: deps.push_back(object.global_position)

## Provide an input from another card's output.
class InputSlot extends Slot:
	var _invoke: Callable
	func _init(invoke: Callable) -> void:
		self._invoke = invoke
		self.num_args = invoke.get_argument_count()
	func can_connect_to(object):
		return object is Card and object.slots.any(func (s):
			return s is OutputSlot and self.num_args == s.num_args)
	func connect_to(from: Node, object: Node):
		var output = object.get_output_slot()
		output.connect_to(object, from)
	func invoke(args):
		self._invoke.callv(args)

## Provide an output from a card, to be used by an [InputSlot].
class OutputSlot extends Slot:
	var connected_input_node_path: NodePath
	func _init(num_args: int) -> void:
		self.num_args = num_args
	func get_connected(node):
		return node.get_node_or_null(connected_input_node_path)
	func get_connected_input(node):
		var c = get_connected(node)
		return c.get_input_slot() if c else null
	func invoke(card: Card, args: Array = []):
		assert(self.num_args == args.size())
		var i = get_connected_input(card)
		if i: i.invoke(args)
	func can_connect_to(object):
		return object is Card and object.slots.any(func (s):
			return s is InputSlot and self.num_args == s.num_args)
	func connect_to(from: Node, object: Node):
		connected_input_node_path = from.get_path_to(object)
	func check_disconnect(card: Card):
		var o = get_connected(card)
		if o and o.global_position.distance_to(card.global_position) > MAX_CONNECTION_DISTANCE:
			connected_input_node_path = NodePath()
	func draw(node):
		var to = get_connected(node)
		if to: draw_connection(node, to)

## Output an object from your card, for example a CollisionInfo.
class ObjectOutputSlot extends OutputSlot:
	func _init() -> void:
		super._init(1)

## Create a fixed connection to some object.
class FixedSlot extends Slot:
	var connected_input_node_path: NodePath
	var object_path: NodePath
	func get_connected(node):
		return node.get_node_or_null(connected_input_node_path)
	func get_connected_input(node):
		return get_connected(node).get_input_slot()
	func get_object(card: Card):
		return card.get_node_or_null(connected_input_node_path)
	func can_connect_to(object):
		return object is Card and object.slots.any(func (s):
			return (s is InputSlot or s is OutputSlot) and self.num_args == s.num_args)
	func connect_to(from: Node, object: Node):
		var slot = object.slots.filter(func (s):
			return (s is InputSlot or s is OutputSlot) and self.num_args == s.num_args)[0]
		if slot is InputSlot:
			connected_input_node_path = from.get_path_to(object)
		else:
			var output = object.get_output_slot()
			output.connect_to(object, from)
	func check_disconnect(card: Card):
		var o = get_connected(card)
		if o and o.global_position.distance_to(card.global_position) > MAX_CONNECTION_DISTANCE:
			connected_input_node_path = NodePath()
	func invoke(card: Card, args: Array = []):
		assert(self.num_args == args.size())
		var i = get_connected_input(card)
		var object = card.get_node_or_null(object_path)
		if i and object: i.invoke([object])
	func draw(node):
		var object = node.get_node_or_null(object_path)
		if object: draw_connection(node, object, true)

class NamedSlot extends Slot:
	func _init(name: String) -> void:
		self.name = name

@export var disable = false:
	set(v):
		disable = v
		queue_redraw()
	get:
		return disable

func get_input_slot():
	for s in slots:
		if s is InputSlot: return s
	return null

func get_output_slot():
	for s in slots:
		if s is OutputSlot: return s
	return null

var slots: Array[Slot]
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

func setup(name: String, description: String, type: Type, slots: Array[Slot]):
	if not show_cards(): return
	var type_icon
	match type:
		Type.Trigger: type_icon = "Signals"
		Type.Effect: type_icon = "PreviewSun"
		Type.Store: type_icon = "CylinderMesh"
	
	visual.setup(name, description, get_icon_name(), type_icon)
	
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
