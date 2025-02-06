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
	node.set_meta("cards_ignore", true)

## Such that the debugger shows the name at the top
var card_name:
	get: return get_card_name()

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
	get: return cards_parent.get_children().filter(func(s): return s is Card)

func _init(custom_build = null):
	var parent = null
	if not active_card_list.is_empty():
		parent = active_card_list.back()
		parent.cards_parent.add_child(self)
	setup(parent, custom_build)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		disconnect_all()

func setup(parent: Card, custom_build = null):
	self.parent = parent
	if not id: id = uuid.v4()
	build_cards_list(custom_build)

func build_cards_list(custom_build = null):
	push_active_card_list(self)
	if custom_build: custom_build.call()
	else: s()
	pop_active_card_list()
	cards.append_array(cards_parent.get_children())

func visual_setup():
	visual = preload("res://addons/cards/CardVisual.tscn").instantiate()
	visual.dragging.connect(func (d): dragging = d)
	visual.paused = paused
	add_child(visual)
	
	v()

func _ready() -> void:
	connection_draw_node.card = self
	add_child(connection_draw_node)
	
	scale = get_base_scale()
	
	var collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(100, 100)
	set_ignore_object(collision)
	cards_parent.add_child(collision)
	cards_parent.card_scale = 1.1
	cards_parent.light_background = true
	
	visual_setup()
	get_card_boundary().card_entered(self)
	
	for card in cards:
		card.setup_finished()
		if card is CellCard:
			for element in card.get_extra_ui(): ui(element)

var cards_parent = CardBoundary.new()

func add_card(card: Card):
	cards_parent.add_child(card)
	card.parent = self
	return card

## Setup function DSL
func s(): pass
func v(): pass
func title(t: String): visual.title(t)
func description(t: String): visual.description(t)
func container_size(t: Vector2): visual.container_size(t)
func icon(t: Texture): visual.icon(t)
func icon_data(t: String): visual.icon_data(t)
func ui(t: Control): visual.ui(t)
func c(other: Card):
	outgoing.push_back(get_path_to(other))
	other.incoming.push_back(other.get_path_to(self))
func c_named(name: String, other: Card):
	get_or_put(named_outgoing, name).push_back(get_path_to(other))
	get_or_put(other.named_incoming, name).push_back(other.get_path_to(self))
## If your Card defers delivery of outputs you can signal here that it is
## possible to connect it in a cycle. (Otherwise, if inputs are synchronously
## delivered to outputs we get an infinite loop).
func allow_cycles(): _allows_cycles = true

var parent: Node
var _allows_cycles = false
@export var incoming: Array[NodePath] = []
@export var outgoing: Array[NodePath] = []
@export var named_outgoing: Dictionary[String, Array] = {}
@export var named_incoming: Dictionary[String, Array] = {}

func allows_cycles(): return _allows_cycles
func get_out_signatures(signatures: Array, visited = []):
	for card in cards:
		if card is OutCard: card.get_out_signatures(signatures, visited)

func get_in_signatures(signatures: Array):
	for card in cards:
		if card is InCard: signatures.push_back(card.signature)

func setup_finished():
	pass

func mark_activated(from, args):
	if from and is_inside_tree():
		connection_draw_node.on_activated(from.parent)
		from.parent.show_feedback_for(self, args)
		from.mark_signaled_feedback()

func show_feedback_for(to: Node, args: Array):
	connection_draw_node.show_feedback_for(to, args)

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	for input in cards:
		if ((not named and input is InCard and not input is NamedInCard) or
			(named and input is NamedInCard and input.input_name == named)):
			if signature.compatible_with(input.signature):
				input.invoke(args, signature, "", source_out)
				mark_activated(source_out, args)

static func get_or_put(dict, key):
	if not dict.has(key): dict.set(key, [])
	return dict.get(key)
static func not_null(obj): return obj != null
func get_incoming() -> Array:
	return incoming.map(func (p): return get_node_or_null(p)).filter(not_null)
func get_outgoing() -> Array:
	return outgoing.map(func (p): return get_node_or_null(p)).filter(not_null)

## Return true if this named connection can exist as part of a cycle
func cycles_allowed_for(name: String): return false
## Return all outgoing connections that should be considered for cycle avoidance
func get_named_outgoing_for_cycles() -> Array:
	var out = []
	for name in named_outgoing:
		for p in named_outgoing[name]:
			var card = get_node_or_null(p)
			if card and not card.cycles_allowed_for(name): out.append(card)
	return out
func get_named_outgoing() -> Array: return _get_named(named_outgoing)
func get_named_incoming() -> Array: return _get_named(named_incoming)
func _get_named(dict) -> Array:
	var out = []
	for name in dict:
		for p in dict[name]:
			var card = get_node_or_null(p)
			if card: out.append(card)
	return out

func get_first_named_incoming_at(name: String):
	if not named_incoming.has(name): return null
	var p = named_incoming.get(name)[0]
	return get_node_or_null(p) if p else null

func get_named_incoming_at(name: String):
	return named_incoming.get(name, []).map(func (p): return get_node_or_null(p)).filter(not_null)

func get_all_incoming() -> Array:
	var all = []
	all.append_array(get_incoming())
	all.append_array(get_named_incoming())
	return all
func get_all_outgoing() -> Array:
	var all = []
	all.append_array(get_outgoing())
	all.append_array(get_named_outgoing())
	return all
func get_all_connected() -> Array:
	var all = []
	all.append_array(get_outgoing())
	all.append_array(get_named_outgoing())
	all.append_array(get_incoming())
	all.append_array(get_named_incoming())
	return all

## Trace from this card to any inputs
func get_connected_inputs(out: Array, seen: Dictionary):
	if seen.has(self): return
	seen[self] = true
	for i in get_all_incoming():
		if i is InCard: out.push_back(i)
		else: i.get_connected_inputs(out, seen)

func disconnect_all():
	for c in get_all_connected():
		object_disconnect_from(self, c)

static func get_meta_or(object: Node, name: String, default: Callable):
	if not object.has_meta(name) or not object.get_meta(name): object.set_meta(name, default.call())
	return object.get_meta(name)
static func get_object_cards(object: Node):
	if object is Card: return object.cards
	else: return get_object_out_cards(object)
static func get_object_out_signatures(object: Node, out: Array, visited = []):
	if object is Card: return object.get_out_signatures(out, visited)
	for card in get_object_cards(object):
		if card is OutCard: card.get_out_signatures(out, visited)
static func objects_have_same_out_signatures(a: Node, b: Node):
	var a_sig = [] as Array[Signature]
	var b_sig = [] as Array[Signature]
	get_object_out_signatures(a, a_sig)
	get_object_out_signatures(b, b_sig)
	for s1 in a_sig:
		if not b_sig.any(func(s2): return s1.eq(s2)): return false
	return true

static func get_object_out_cards(object: Node):
	# FIXME storing the card in meta led to serialization issues.
	# Not sure if we will get a noticeable performance impact from recreating the
	# card on every request.
	if object.has_meta("cards_ignore"): return []
	if object.has_meta("out_cards"): return object.get_meta("out_cards")
	var c = OutCard.static_signature(t(object.get_class()), true)
	c.parent = object
	c.remembered = [object]
	c.remembered_signature = c.signature
	var g = OutCard.static_signature(grp(object.get_groups()), true)
	if not Engine.is_editor_hint(): object.set_meta("out_cards", [c, g])
	return [c, g]
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
static func delete_from_dict_list(dict: Dictionary, value: NodePath):
	for key in dict:
		if try_erase(dict[key], value): return true
	return false
static func try_erase(array: Array, value: NodePath):
	if array.has(value):
		array.erase(value)
		return true
	return false
static func _notify_disconnect_incoming(from: Node, to: Node): if to is Card: to.incoming_disconnected(from)
static func _notify_disconnect_outgoing(from: Node, to: Node): if from is Card: from.outgoing_disconnected(to)
static func object_disconnect_from(from: Node, to: Node):
	_object_disconnect_from(from, to)
	_object_disconnect_from(to, from)
static func _object_disconnect_from(from: Node, to: Node):
	var p = from.get_path_to(to)
	if try_erase(get_object_incoming(from), p): return _notify_disconnect_incoming(to, from)
	if try_erase(get_object_outgoing(from), p): return _notify_disconnect_outgoing(from, to)
	if delete_from_dict_list(get_object_named_outgoing(from), p): return _notify_disconnect_outgoing(from, to)
	if delete_from_dict_list(get_object_named_incoming(from), p): return _notify_disconnect_incoming(to, from)
	assert("node to disconnect from not found")
static func connect_to(from: Node, to: Node, named = ""):
	if named:
		get_or_put(get_object_named_outgoing(from), named).push_back(from.get_path_to(to))
		get_or_put(get_object_named_incoming(to), named).push_back(to.get_path_to(from))
		if from is Card: from.outgoing_connected(to)
		if to is Card: to.incoming_connected(to)
	else:
		get_object_outgoing(from).push_back(from.get_path_to(to))
		get_object_incoming(to).push_back(to.get_path_to(from))
		if from is Card: from.outgoing_connected(to)
		if to is Card: to.incoming_connected(to)

func _check_disconnect(them: Node2D):
	var my_boundary = get_card_boundary()
	var their_boundary = get_card_boundary()
	if (global_position.distance_to(them.global_position) > MAX_CONNECTION_DISTANCE
		or my_boundary != their_boundary):
		object_disconnect_from(self, them)

const ALWAYS_RECONNECT = false
static func always_reconnect():
	return ALWAYS_RECONNECT and not Engine.is_editor_hint()

func _process(delta: float) -> void:
	if dragging and not Engine.is_editor_hint():
		CardBoundary.card_moved(self)
		# editor_sync("cards:set_prop", [id, "position", position])
	
	if disable: return
	if dragging or always_reconnect():
		for card in get_outgoing(): _check_disconnect(card)
		for card in get_incoming(): _check_disconnect(card)
		for card in get_named_outgoing(): _check_disconnect(card)
		for card in get_named_incoming(): _check_disconnect(card)
		
		CardBoundary.traverse_connection_candidates(self, func (obj):
			if ((obj is Card or obj.get_parent() == get_parent()) and
			not obj.has_meta("cards_ignore") and
			global_position.distance_to(obj.global_position) <= MAX_CONNECTION_DISTANCE):
				try_connect(obj))
	
	connection_draw_node.check_redraw(delta)

func _physics_process(delta: float) -> void:
	if not cards_parent.is_inside_tree() and not disable and not Engine.is_editor_hint():
		for c in cards:
			if not c.disable: c._physics_process(delta)

static func _each_input_candidate(object: Node, cb: Callable, named: bool):
	if not object is Card: return
	for card in object.cards:
		if (named and card is NamedInCard or
			not named and not card is NamedInCard and card is InCard): cb.call(card)

func try_connect(them: Node):
	_each_input_candidate(them, func (card): card.try_connect_in(self), true)
	_each_input_candidate(them, func (card): card.try_connect_in(self), false)
	_each_input_candidate(self, func (card): card.try_connect_in(them), true)
	_each_input_candidate(self, func (card): card.try_connect_in(them), false)

static func get_remembered_for(object: Node, signature: Signature):
	if object is InCard or object is OutCard: return object._get_remembered_for(signature)
	for card in get_object_cards(object):
		if card is OutCard:
			var val = get_remembered_for(card, signature)
			if val != null: return val
	return null

func get_card_boundary() -> CardBoundary:
	return CardBoundary.get_card_boundary(self)

func get_base_scale():
	var s = get_card_boundary().card_scale
	return Vector2(s, s)

func card_parent_in_world():
	if not parent: return self
	if not parent is Card: return parent
	return parent.card_parent_in_world()

func incoming_disconnected(obj: Node):
	connection_draw_node.incoming_disconnected(obj)
	for input in cards:
		if input is InCard: input.incoming_disconnected(obj)
func outgoing_disconnected(obj: Node):
	connection_draw_node.outgoing_disconnected(obj)
func outgoing_connected(obj: Node):
	connection_draw_node.outgoing_disconnected(obj)
func incoming_connected(obj: Node):
	pass

func editor_sync_prop(name: String):
	editor_sync("cards:set_prop", [id, name, get(name)])

func _forward_canvas_gui_input(event: InputEvent, undo_redo):
	if event is InputEventKey and event.key_label == KEY_TAB and event.pressed:
		visual.expanded = not visual.expanded
		return true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	return false

func _get_property_list():
	var properties = []
	
	for card in cards:
		if card is CellCard:
			properties.append({
				"name": card.data_name,
				"type": Signature.type_signature(card.type, true),
				"hint": PROPERTY_HINT_NONE
			})
	return properties

func _get(property):
	for card in cards:
		if card is CellCard and card.data_name == property:
			return card.data

func _set(property, value):
	for card in cards:
		if card is CellCard and card.data_name == property:
			card.data = value
			return true
	return false

func can_edit(): return true

func get_selection_manager() -> CardCamera:
	return visual.get_selection_manager()

func get_card_name():
	return get_script().get_global_name()

func get_stored_data():
	for card in cards:
		if card is CellCard: return card.data

func clone():
	return get_script().new()

func serialize_constructor():
	return "{0}.new()".format([get_card_name()])

func serialize_gdscript(overwrite_name: String = "", size: Vector2 = Vector2.ZERO):
	
	return "@tool
extends Card
class_name {name}

func v():
	title(\"{title}\")
	description(\"{description}\")
	icon_data(\"{icon_data}\"){size}{allow_cycles}

func s():
{cards}".format({
		"name": overwrite_name if overwrite_name else get_card_name(),
		"title": visual.get_title(),
		"description": visual.get_description(),
		"icon_data": visual.get_icon_data(),
		"allow_cycles": "\n\tallow_cycles()" if _allows_cycles else "",
		"size": "\n\tcontainer_size(Vector2" + str(size) + ")" if size != Vector2.ZERO else "",
		"cards": serialize_card_construction(cards)
	})

static func serialize_card_construction(cards: Array):
	if cards.is_empty(): return "pass"
	var cards_desc = ""
	var var_names = {}
	var count = {}
	for c in cards:
		var n = c.get_card_name()
		var num = count.get(n, 0) + 1
		count.set(n, num)
		var name = n.to_snake_case()
		if num > 1: name += "_" + str(num)
		var_names[c] = name
	
	for c in cards:
		var n = var_names.get(c)
		cards_desc += "\tvar {0} = {1}\n".format([n, c.serialize_constructor()])
		cards_desc += "\t{0}.position = Vector2{1}\n".format([n, c.position])
		for i in range(0, c.cards.size()):
			if c.cards[i] is CellCard:
				cards_desc += "\t{0}.cards[{1}].data = {2}\n".format([n, i, Signature.data_to_expression(c.cards[i].data)])
	if not cards.is_empty(): cards_desc += "\t\n"
	else: cards_desc = "\tpass"
	for c in cards:
		for them in c.get_outgoing():
			if cards.has(them): cards_desc += "\t{0}.c({1})\n".format([var_names[c], var_names[them]])
		for name in c.named_outgoing:
			for their_path in c.named_outgoing[name]:
				var them = c.get_node_or_null(their_path)
				if them and cards.has(them):
					cards_desc += "\t{0}.c_named(\"{2}\", {1})\n".format([var_names[c], var_names[them], name])
	return cards_desc

# DSL for signatures
static func trg(): return Signature.TriggerSignature.new()
static func none(): return Signature.VoidSignature.new()
static func t(type: String): return Signature.TypeSignature.new(type)
static func grp(group_names: Array[StringName]): return Signature.GroupSignature.new(group_names)
static func cmd(name: String, arg = null): return Signature.CommandSignature.new(name, arg)
static func any(): return Signature.GenericTypeSignature.new()
static func struct(props, methods): return Signature.StructSignature.new(props, methods)
