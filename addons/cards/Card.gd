@tool
extends Node2D
class_name Card

const MAX_CONNECTION_DISTANCE = 150

static var active_card_list = []
static func push_active_card_list(list):
	active_card_list.push_back(list)
static func pop_active_card_list():
	active_card_list.pop_back()

static func editor_sync(message: String, args: Array):
	if EngineDebugger.is_active(): EngineDebugger.send_message(message, args)

static func get_id(node: Node):
	if node is Card: return node.id
	if node is CardBoundary: return node.id
	push_error("missing get_id")

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

var cards: Array[Node]:
	get: return cards_parent.get_children()

func _init():
	if not active_card_list.is_empty(): active_card_list.back().add_child(self)

func setup(parent: Card):
	self.parent = parent
	if not id: id = uuid.v4()
	
	push_active_card_list(cards_parent)
	s()
	pop_active_card_list()
	cards.append_array(cards_parent.get_children())
	
	for card in cards: card.setup(self)
	
	#var outputs = [] as Array[Signature]
	#get_out_signatures(outputs)
	#for other in get_all_incoming():
		#var inputs = []
		#other.get_in_signatures(inputs)
		#assert(outputs.any(func (o): return inputs.any(func (i): return o.compatible_with(i))))

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
	
	for card in cards:
		card.setup_finished()
		if card is CellCard:
			for element in card.get_extra_ui(): ui(element)

var cards_parent = Node2D.new()

## Setup function DSL
func s(): pass
func title(t: String): if visual: visual.title(t)
func description(t: String): if visual: visual.description(t)
func icon(t: String): if visual: visual.icon(t)
func ui(t: Control): if visual: visual.ui(t)
func c(other: Card):
	outgoing.push_back(get_path_to(other))
	other.incoming.push_back(other.get_path_to(self))
func c_named(name: String, other: Card):
	get_or_put(named_outgoing, name).push_back(get_path_to(other))
	get_or_put(other.named_incoming, name).push_back(other.get_path_to(self))
## If your Card defers delivery of outputs you can signal here that it is
## possible to connect it in a cycle. (Otherwise, if inputs are synchronously
## delivered to outputs we get an infinite loop).
func allow_cycles():
	pass

var parent: Node
@export var incoming: Array[NodePath] = []
@export var outgoing: Array[NodePath] = []
@export var named_outgoing: Dictionary[String, Array] = {}
@export var named_incoming: Dictionary[String, Array] = {}

func get_out_signatures(signatures: Array):
	for card in cards:
		if card is OutCard: card.get_out_signatures(signatures)

func get_in_signatures(signatures: Array):
	for card in cards:
		if card is InCard: signatures.push_back(card.signature)

func invoke_inputs(args: Array, signature: Signature, named = ""):
	for input in cards:
		if not named and input is InCard or named and input is NamedInCard and input.input_name == named:
			if signature.compatible_with(input.signature):
				input.invoke(args, signature)

func invoke_outputs(args: Array, signature: Signature):
	for card in get_outgoing():
		card.invoke(args, signature)

func setup_finished(): pass

func invoke(args: Array, signature: Signature, named = ""):
	invoke_inputs(args, signature, named)

static func get_or_put(dict, key):
	if not dict.has(key): dict.set(key, [])
	return dict.get(key)
static func not_null(obj): return obj != null
func get_incoming() -> Array:
	return incoming.map(func (p): return get_node_or_null(p)).filter(not_null)
func get_outgoing() -> Array:
	return outgoing.map(func (p): return get_node_or_null(p)).filter(not_null)

func get_named_outgoing() -> Array: return _get_named(named_outgoing)
func get_named_incoming() -> Array: return _get_named(named_incoming)
func _get_named(dict) -> Array:
	var out = []
	for name in dict:
		for p in dict[name]:
			var card = get_node_or_null(p)
			if card: out.append(card)
	return out

func get_named_incoming_at(name: String):
	var p = named_incoming.get(name)
	return get_node_or_null(p) if p else null

func get_named_outcoming_at(name: String):
	var p = named_outgoing.get(name)
	return get_node_or_null(p) if p else null

func get_all_incoming() -> Array:
	var all = []
	all.append_array(get_incoming())
	all.append_array(get_named_incoming())
	return all

func disconnect_all():
	pass

static func get_meta_or(object: Node, name: String, default: Callable):
	if not object.has_meta(name) or not object.get_meta(name): object.set_meta(name, default.call())
	return object.get_meta(name)
static func get_object_cards(object: Node):
	if object is Card: return object.cards
	else: return [get_object_out_card(object)]
static func get_object_out_card(object: Node):
	# FIXME storing the card in meta led to serialization issues.
	# Not sure if we will get a noticeable performance impact from recreating the
	# card on every request.
	var c = OutCard.static_signature(t(object.get_class()), true)
	c.parent = object
	c.remembered = [object]
	c.remembered_signature = c.signature
	return c
static func get_object_incoming(object: Node):
	return object.incoming if object is Card else []
static func get_object_outgoing(object: Node):
	if object is Card: return object.outgoing
	else: return get_meta_or(object, "cards_outgoing", func (): return [])
static func get_object_named_outgoing(object: Node):
	if object is Card: return object.named_outgoing
	else: return get_meta_or(object, "cards_named_outgoing", func (): return {})
static func get_object_named_incoming(object: Node):
	return object.named_incoming if object is Card else {}
static func unset_value(dict: Dictionary, value: NodePath):
	for key in dict:
		if dict[key] == value:
			dict[key] = NodePath()
			return true
	return false
static func try_erase(array: Array, value: NodePath):
	if array.has(value):
		array.erase(value)
		return true
	return false
static func _notify_disconnect_incoming(from: Node, to: Node): if to is Card: to.incoming_disconnected(from)
static func _notify_disconnect_outgoing(from: Node, to: Node): if from is Card: from.incoming_disconnected(to)
static func object_disconnect_from(from: Node, to: Node):
	_object_disconnect_from(from, to)
	_object_disconnect_from(to, from)
static func _object_disconnect_from(from: Node, to: Node):
	var p = from.get_path_to(to)
	if try_erase(get_object_incoming(from), p): return _notify_disconnect_incoming(to, from)
	if try_erase(get_object_outgoing(from), p): return _notify_disconnect_outgoing(from, to)
	if unset_value(get_object_named_outgoing(from), p): return _notify_disconnect_outgoing(from, to)
	if unset_value(get_object_named_incoming(from), p): return _notify_disconnect_incoming(to, from)
	assert("node to disconnect from not found")
static func connect_to(from: Node, to: Node, named = ""):
	if named:
		get_or_put(get_object_named_outgoing(from), named).push_back(from.get_path_to(to))
		get_or_put(get_object_named_incoming(to), named).push_back(to.get_path_to(from))
	else:
		get_object_outgoing(from).push_back(from.get_path_to(to))
		get_object_incoming(to).push_back(to.get_path_to(from))

func _check_disconnect(them: Node2D):
	var my_boundary = get_card_boundary()
	var their_boundary = get_card_boundary()
	if (global_position.distance_to(them.global_position) > MAX_CONNECTION_DISTANCE
		or my_boundary != their_boundary):
		object_disconnect_from(self, them)

func _process(delta: float) -> void:
	if dragging and not Engine.is_editor_hint():
		CardBoundary.card_moved(self)
		editor_sync("cards:set_prop", [id, "position", position])
	
	if disable: return
	if dragging:
		for card in get_outgoing(): _check_disconnect(card)
		for card in get_incoming(): _check_disconnect(card)
		for card in get_named_outgoing(): _check_disconnect(card)
		for card in get_named_incoming(): _check_disconnect(card)
		
		CardBoundary.traverse_connection_candidates(self, func (obj):
			if (obj is Card or obj.get_parent() == get_parent()) and global_position.distance_to(obj.global_position) <= MAX_CONNECTION_DISTANCE:
				try_connect(obj))
	
	connection_draw_node.check_redraw(delta)

func _physics_process(delta: float) -> void:
	for c in cards:
		c._physics_process(delta)

static func _each_input_candidate(object: Node, cb: Callable, named: bool):
	if not object is Card: return
	for card in object.cards:
		if (named and card is NamedInCard or
			not named and not card is NamedInCard and card is InCard): cb.call(card)

func try_connect(them: Node):
	_each_input_candidate(self, func (card): card.try_connect(them), true)
	_each_input_candidate(them, func (card): card.try_connect(self), true)
	_each_input_candidate(self, func (card): card.try_connect(them), false)
	_each_input_candidate(them, func (card): card.try_connect(self), false)

static func get_remembered_for(object: Node, signature: Signature):
	if object is InCard or object is OutCard: return object._get_remembered_for(signature)
	for card in get_object_cards(object):
		if card is OutCard:
			var val = get_remembered_for(card, signature)
			if val != null: return val
	return null

func get_card_boundary():
	return CardBoundary.get_card_boundary(self)

func get_base_scale():
	var s = get_card_boundary().card_scale
	return Vector2(s, s)

func incoming_disconnected(obj: Node):
	for input in cards:
		if input is InCard: input.incoming_disconnected(obj)
func outgoing_disconnected(obj: Node): pass

func editor_sync_prop(name: String):
	editor_sync("cards:set_prop", [id, name, get(name)])

func _forward_canvas_gui_input(event: InputEvent, undo_redo):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	return false

# DSL for signatures
static func trg(): return Signature.TriggerSignature.new()
static func none(): return Signature.VoidSignature.new()
static func t(type: String): return Signature.TypeSignature.new(type)
static func cmd(name: String, arg = null): return Signature.CommandSignature.new(name, arg)
static func any(): return Signature.GenericTypeSignature.new()
static func struct(props, methods): return Signature.StructSignature.new(props, methods)
