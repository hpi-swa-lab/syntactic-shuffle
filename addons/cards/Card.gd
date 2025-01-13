@tool
extends Node2D
class_name Card

enum Type {
	Trigger,
	Effect,
	Store
}

const SHOW_IN_GAME = true
const DEFAULT_SCALE = Vector2(0.2, 0.2)
const MAX_CONNECTION_DISTANCE = 150

static func show_cards():
	return not Engine.is_editor_hint() or SHOW_IN_GAME

static func node_get_slots(node: Node):
	if node is Card: return node.slots
	else: return [ObjectOutputSlot.new()]

static func node_get_slot_by_name(node: Node, name: String):
	if node is Card: return node.get_slot_by_name(name)
	else: return ObjectOutputSlot.new()

static func node_connect_slot(me: Node, my_slot: Slot, them: Node, their_slot: Slot):
	if me is Card: me.connect_slot(my_slot, them, their_slot)

static func node_disconnect_slot(me: Node, my_slot: Slot, them: Node, their_slot: Slot):
	if me is Card: me.disconnect_slot(my_slot, them, their_slot)

## List of connections from this card to other cards.
## The dictionary maps from this card's slot name (such as __output)
## to an array of tuples of [NodePath, slot name].
@export var connections: Dictionary[String, Array] = {}

@export var locked = false:
	get: return locked
	set(v):
		locked = v
		if visual: visual.locked = v

@export var disable = false:
	set(v):
		disable = v
		if connection_draw_node: connection_draw_node.queue_redraw()
		if disable: disconnect_all()
	get: return disable

var slots: Array[Slot]
var visual: CardVisual
var connection_draw_node = CardConnectionsDraw.new()
var dragging: bool:
	set(v):
		if locked: v = false
		if v == dragging: return
		
		var was_dragging = dragging != null
		dragging = v
		if was_dragging and not dragging:
			CardBoundary.get_card_boundary(self).card_dropped(self)
		if dragging:
			CardBoundary.get_card_boundary(self).card_picked_up(self)
		connection_draw_node.queue_redraw()
		create_tween().tween_property(visual, "scale",
				DEFAULT_SCALE * 1.1 if dragging else DEFAULT_SCALE,
				0.17 if dragging else 0.13).from_current().set_trans(Tween.TRANS_EXPO)
	get: return dragging

func _ready() -> void:
	if not show_cards(): return
	
	# we draw connections in a separate node whose z-index is below all content,
	# such that the connections appear under the cards
	connection_draw_node.card = self
	add_child(connection_draw_node)
	
	visual = preload("res://addons/cards/CardVisual.tscn").instantiate()
	visual.scale = DEFAULT_SCALE
	visual.dragging.connect(func (d): dragging = d)
	visual.locked = locked
	add_child(visual)

func setup(name: String, description: String, type: Type, slots: Array[Slot], extra_ui: Array[Control] = []):
	self.slots = slots
	for s in slots:
		if not connections.has(s.get_slot_name()): connections[s.get_slot_name()] = []
		s.ready(self)
	
	if show_cards():
		var type_icon
		match type:
			Type.Trigger: type_icon = "Signals.svg"
			Type.Effect: type_icon = "PreviewSun.svg"
			Type.Store: type_icon = "CylinderMesh.svg"
		visual.setup(name, description, get_icon_name(), type_icon, extra_ui)

func get_icon_name():
	if get_script():
		var name = get_script().resource_path.get_file().split('.')[0]
		return G.at("addon").cards[name]
	return null

func _process(delta: float) -> void:
	if not show_cards(): return
	
	if dragging and not Engine.is_editor_hint(): CardBoundary.card_moved(self)
	
	if disable: return
	if dragging:
		var boundary = get_card_boundary()
		# check for disconnects
		for slot_name in connections:
			var connections_iter = connections[slot_name].duplicate()
			for i in range(0, connections_iter.size()):
				var them = get_node_or_null(connections_iter[i][0])
				if not (them != null
						and global_position.distance_to(them.global_position) <= MAX_CONNECTION_DISTANCE
						and boundary == CardBoundary.get_card_boundary(them)):
					var my_slot = get_slot_by_name(slot_name)
					var their_slot = node_get_slot_by_name(them, connections_iter[i][1])
					disconnect_slot(my_slot, them, their_slot, i)
					if them: node_disconnect_slot(them, their_slot, self, my_slot)
		
		# check for connects
		for my_slot in slots:
			CardBoundary.traverse_connection_candidates(self, func (obj):
				if not obj is CanvasItem or global_position.distance_to(obj.global_position) > MAX_CONNECTION_DISTANCE:
					return
				for their_slot in Card.node_get_slots(obj):
					if my_slot.can_connect_to(obj, their_slot):
						connect_slot(my_slot, obj, their_slot)
						node_connect_slot(obj, their_slot, self, my_slot))
	
	connection_draw_node.check_redraw(delta)

func connect_slot(my_slot: Slot, them: Node, their_slot: Slot):
	var pair = [get_path_to(them), their_slot.get_slot_name()]
	var list = connections[my_slot.get_slot_name()]
	if not list.has(pair):
		list.push_back(pair)
		my_slot.on_connect(them, their_slot)

func disconnect_slot(my_slot: Slot, them: Node, their_slot: Slot, index: int = -1):
	var list = connections[my_slot.get_slot_name()]
	if not them and index >= 0:
		list.remove_at(index)
	else:
		var path = get_path_to(them)
		list.erase([path, their_slot.get_slot_name()])
		my_slot.on_disconnect(them, their_slot)

func disconnect_all():
	for list in connections:
		connections[list].clear()

func get_extent() -> Vector2:
	return visual.get_extent()

func get_object_input():
	return get_slot_by_name("__object").get_object()

func activate_object_input():
	connection_draw_node.on_activated(get_object_input())

func get_slot_by_name(name: String) -> Slot:
	for s in slots:
		if s.get_slot_name() == name:
			return s
	push_error("slot not found")
	return null

func invoke_output(signature_name: String, args: Array, name = "__output"):
	get_slot_by_name(name).invoke(signature_name, args)

func get_card_boundary():
	return CardBoundary.get_card_boundary(self)

func _forward_canvas_gui_input(event: InputEvent, undo_redo):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	return false
