@tool
extends Node2D
class_name Card

enum Type {
	Trigger,
	Effect,
	Store
}

const SHOW_IN_GAME = true
const MAX_CONNECTION_DISTANCE = 150

static func editor_sync(message: String, args: Array):
	if EngineDebugger.is_active(): EngineDebugger.send_message(message, args)

static func show_cards():
	return not Engine.is_editor_hint() or SHOW_IN_GAME

static func get_id(node: Node):
	if node is Card: return node.id
	if node is CardBoundary: return node.id
	push_error("missing get_id")

static func node_get_slots(node: Node) -> Array:
	if node is Card: return node.slots
	else:
		if node.has_meta("slots"): return node.get_meta("slots") as Array[Slot]
		else:
			var slots = [ObjectOutputSlot.new()] as Array[Slot]
			node.set_meta("slots", slots)
			return slots

static func node_get_connections(node: Node) -> Dictionary[String, Array]:
	if node is Card: return node.slots
	else:
		if node.has_meta("connections"): return node.get_meta("connections") as Dictionary[String, Array]
		else:
			var connections = {"__object": []} as Dictionary[String, Array]
			node.set_meta("connections", connections)
			return connections

static func node_get_slot_by_name(node: Node, name: String) -> Slot:
	if node is Card: return node.get_slot_by_name(name)
	else: return ObjectOutputSlot.new()

static func node_connect_slot(me: Node, my_slot: Slot, them: Node, their_slot: Slot):
	if me is Card: me.connect_slot(my_slot, them, their_slot)

static func node_disconnect_slot(me: Node, my_slot: Slot, them: Node, their_slot: Slot):
	if me is Card: me.disconnect_slot(my_slot, them, their_slot)

static func set_ignore_object(node: Node):
	node.set_meta("_cards_ignore", true)

var _connections: Dictionary[String, Array] = {}
## List of connections from this card to other cards.
## The dictionary maps from this card's slot name (such as __output)
## to an array of tuples of [NodePath, slot name].
@export var connections: Dictionary[String, Array]:
	get: return _get_connections()
	set(v):
		_connections = v
func _get_connections() -> Dictionary[String, Array]: return _connections

## Not currently able to move
@export var locked = false:
	get: return locked
	set(v):
		locked = v
		if visual: visual.locked = v

## Not currently able to move, connect, or emit
@export var disable = false:
	set(v):
		disable = v
		if connection_draw_node: connection_draw_node.queue_redraw()
		if disable: disconnect_all()
		if visual: visual.paused = paused
	get: return disable

## Not currently activating triggers or returning objects but can be
## connected to other cards and objects
@export var paused = false:
	set(v):
		paused = v
		if visual: visual.paused = v
	get: return paused or disable

@export var id: String

var slots: Array[Slot]:
	get: return _get_slots()
	set(v): _set_slots(v)

var _slots: Array[Slot]
func _get_slots(): return _slots
func _set_slots(v: Array[Slot]): _slots = v

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
			create_tween().tween_property(self, "rotation", 0, 0.1).set_trans(Tween.TRANS_EXPO)
			create_tween().tween_property(self, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_EXPO)
			CardBoundary.get_card_boundary(self).card_picked_up(self)
		connection_draw_node.queue_redraw()
		var s = get_base_scale() * 1.1 if dragging else get_base_scale()
		create_tween().tween_property(visual, "scale",
				s, 0.17 if dragging else 0.13).from_current().set_trans(Tween.TRANS_EXPO)
	get: return dragging

func _ready() -> void:
	if not show_cards(): return
	
	# we draw connections in a separate node whose z-index is below all content,
	# such that the connections appear under the cards
	connection_draw_node.card = self
	add_child(connection_draw_node)
	
	visual = preload("res://addons/cards/CardVisual.tscn").instantiate()
	visual.scale = get_base_scale()
	visual.dragging.connect(func (d): dragging = d)
	visual.locked = locked
	visual.paused = paused
	add_child(visual)
	
	get_card_boundary().card_entered(self)
	
	if not id:
		id = uuid.v4()

## If your Card defers delivery of outputs you can signal here that it is
## possible to connect it in a cycle. (Otherwise, if inputs are synchronously
## delivered to outputs we get an infinite loop).
func allow_cycles() -> bool:
	return false

func setup(name: String, description: String, icon: String, type: Type, slots: Array[Slot], extra_ui: Array[Control] = []):
	self.slots = slots
	for s in slots:
		if not connections.has(s.get_slot_name()): connections[s.get_slot_name()] = []
		s.ready(self)
	
	if show_cards():
		var type_icon
		match type:
			Type.Trigger: type_icon = "trigger.png"
			Type.Effect: type_icon = "event.png"
			Type.Store: type_icon = "CylinderMesh.svg"
		visual.setup(name, description, icon, type_icon, extra_ui)

func _process(delta: float) -> void:
	if not show_cards(): return
	
	if dragging and not Engine.is_editor_hint():
		CardBoundary.card_moved(self)
		editor_sync("cards:set_prop", [id, "position", position])
	
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
		editor_sync("cards:set_prop", [id, "connections", connections])

func editor_sync_prop(name: String):
	editor_sync("cards:set_prop", [id, name, get(name)])

func disconnect_slot(my_slot: Slot, them: Node, their_slot: Slot, index: int = -1):
	var list = connections[my_slot.get_slot_name()]
	if not them and index >= 0:
		list.remove_at(index)
	else:
		var path = get_path_to(them)
		var pair = [path, their_slot.get_slot_name()]
		assert(list.has(pair), "tried to delete connection that did not exist")
		list.erase(pair)
		my_slot.on_disconnect(them, their_slot)
		editor_sync("cards:set_prop", [id, "connections", connections])

func disconnect_all():
	for list in connections:
		connections[list].clear()

func get_object_input():
	if paused: return null
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
	if paused: return
	get_slot_by_name(name).invoke(signature_name, args)

func invoke_generic_output(signature: Array, args: Array, name = "__output"):
	if paused: return
	get_slot_by_name(name).invoke_signature(signature, args)

func get_card_boundary():
	return CardBoundary.get_card_boundary(self)

func get_base_scale():
	var s = get_card_boundary().card_scale
	return Vector2(s, s)

func _forward_canvas_gui_input(event: InputEvent, undo_redo):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	return false
