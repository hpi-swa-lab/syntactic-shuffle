@tool
extends Node2D
class_name Card

const MAX_CONNECTION_DISTANCE = 150

static func editor_sync(message: String, args: Array):
	if EngineDebugger.is_active(): EngineDebugger.send_message(message, args)

static func get_id(node: Node):
	if node is Card: return node.id
	if node is CardBoundary: return node.id
	push_error("missing get_id")

static func node_get_connections(node: Node) -> Dictionary[String, Array]:
	if node is Card: return node.slots
	else:
		if node.has_meta("connections"): return node.get_meta("connections") as Dictionary[String, Array]
		else:
			var connections = {"__object": []} as Dictionary[String, Array]
			node.set_meta("connections", connections)
			return connections

static func set_ignore_object(node: Node):
	node.set_meta("_cards_ignore", true)

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

var visual: CardVisual
var connection_draw_node = CardConnectionsDraw.new()
var dragging: bool:
	set(v):
		if v == dragging: return
		var was_dragging = dragging != null
		dragging = v
		if was_dragging and not dragging:
			CardBoundary.get_card_boundary(self).card_dropped(self)
		if dragging:
			CardBoundary.get_card_boundary(self).card_picked_up(self)
	get: return dragging

var cards: Array[Card] = []

func _init():
	if not active_card_list.is_empty(): active_card_list.back().push_back(self)

func setup(parent: Card):
	self.parent = parent
	if not id: id = uuid.v4()
	
	push_active_card_list(cards)
	s()
	pop_active_card_list()
	
	for card in cards: card.setup(self)

func _ready() -> void:
	connection_draw_node.card = self
	add_child(connection_draw_node)
	
	visual = preload("res://addons/cards/CardVisual.tscn").instantiate()
	visual.scale = get_base_scale()
	visual.dragging.connect(func (d): dragging = d)
	visual.paused = paused
	add_child(visual)
	
	get_card_boundary().card_entered(self)
	
	setup(null)

static var active_card_list = []
static func push_active_card_list(list):
	active_card_list.push_back(list)
static func pop_active_card_list():
	active_card_list.pop_back()

## If your Card defers delivery of outputs you can signal here that it is
## possible to connect it in a cycle. (Otherwise, if inputs are synchronously
## delivered to outputs we get an infinite loop).
func allow_cycles():
	pass

## Setup function DSL
func s():
	pass

func title(t: String): if visual: visual.title(t)
func description(t: String): if visual: visual.description(t)
func icon(t: String): if visual: visual.icon(t)
func ui(t: Control): if visual: visual.ui(t)
func c(other: Card):
	outgoing.push_back(other)
	other.incoming.push_back(self)
func c_named(name: String, other: Card):
	named_outgoing[name] = other
	other.incoming.push_back(self)

var parent: Card
@export var incoming: Array[Card] = []
@export var outgoing: Array[Card] = []
@export var named_outgoing: Dictionary[String, Card] = {}

func get_out_signatures(signatures: Array):
	for card in cards:
		if card is OutCard:
			card.get_out_signatures(signatures)

func invoke_inputs(args: Array, signature: Array[String], named = ""):
	for input in cards:
		if not named and input is InCard or named and input is NamedInCard and input.input_name == named:
			if signature_match(signature, input.signature):
				input.invoke(args, signature)

func invoke_outputs(args: Array, signature: Array[String]):
	for card in get_outgoing():
		card.invoke(args, signature)

func invoke(args: Array, signature: Array[String], named = ""):
	invoke_inputs(args, signature, named)

func signature_match(a: Array[String], b: Array[String]) -> bool:
	if a.is_empty() and b.is_empty(): return true
	if a.size() != b.size(): return false
	for i in range(a.size()):
		if a[i] != b[i] and a[i] != "*" and b[i] != "*":
			return false
	return true

func get_named_outgoing():
	return named_outgoing

func get_incoming() -> Array[Card]:
	return incoming

func get_outgoing() -> Array[Card]:
	return outgoing

func disconnect_all():
	pass

func disconnect_from(them: Card):
	if get_incoming().has(them):
		incoming.erase(them)
		assert(them.get_outgoing().has(self))
		them.get_outgoing().erase(self)
		return
	elif get_outgoing().has(them):
		outgoing.erase(them)
		assert(them.get_incoming().has(self))
		them.get_incoming().erase(self)
		return
	else:
		for name in get_named_outgoing():
			if get_named_outgoing()[name] == them:
				get_named_outgoing()[name] = null
				assert(them.get_incoming().has(self))
				them.get_incoming().erase(self)
				return
	assert("node to disconnect from not found")

func connect_to(them: Card):
	get_outgoing().push_back(them)
	them.get_incoming().push_back(self)

func _check_disconnect(them: Card):
	var my_boundary = get_card_boundary()
	var their_boundary = get_card_boundary()
	if (global_position.distance_to(them.global_position) > MAX_CONNECTION_DISTANCE
		or my_boundary != their_boundary):
		disconnect_from(them)

func _process(delta: float) -> void:
	if dragging and not Engine.is_editor_hint():
		CardBoundary.card_moved(self)
		editor_sync("cards:set_prop", [id, "position", position])
	
	if disable: return
	if dragging:
		# check for disconnects
		for card in get_outgoing(): _check_disconnect(card)
		for card in get_incoming(): _check_disconnect(card)
		for name in get_named_outgoing():
			var them = get_named_outgoing()[name]
			if them: _check_disconnect(them)
		
		# check for connects
		CardBoundary.traverse_connection_candidates(self, func (obj):
			if not obj is Card or global_position.distance_to(obj.global_position) > MAX_CONNECTION_DISTANCE:
				return
			for card in cards:
				if card is InCard: card.try_connect(obj)
				if card is OutCard: card.try_connect(obj))
	
	connection_draw_node.check_redraw(delta)

func get_card_boundary():
	return CardBoundary.get_card_boundary(self)

func get_base_scale():
	var s = get_card_boundary().card_scale
	return Vector2(s, s)



func editor_sync_prop(name: String):
	editor_sync("cards:set_prop", [id, name, get(name)])

func _forward_canvas_gui_input(event: InputEvent, undo_redo):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	return false
