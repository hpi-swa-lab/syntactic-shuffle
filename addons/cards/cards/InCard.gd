@tool
extends Card
class_name InCard

static func trigger():
	var c = InCard.new(trg())
	return c

static func data(signature: Signature):
	var c = InCard.new(signature)
	return c

func _init(signature: Signature):
	self.signature = signature
	super._init()

func clone():
	return get_script().new(signature)

var signature: Signature = Signature.VoidSignature.new():
	get: return signature
	set(v):
		signature = v
		signature_changed()
var out_card

func s():
	# special InCard that the OutCard uses for connection purposes. Would yield
	# an infinite loop if we proceeded here.
	if signature is Signature.OutputAnySignature: return
	
	out_card = OutCard.new()
	out_card.has_static_signature = true
	out_card.signature = signature

func signature_changed():
	if out_card: out_card.signature = signature

func v():
	title("Input")
	description("Receive input.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAKFJREFUOI3FUjESwzAIE71OWfhCPff/T2F2vsCSlS6Oiznj5LpUi+/AQoAA/glhBiU5S+L9vzCPgUBeFaaTDACPjFznXVDszit1sjBjUzX/52iqmyoKYMJMAECJ0ky5owBWWyyOkCEVuVsgxd0CmSt4lm9ysOhc4suMdprzj8khRRspEt6q3YGstYFY21tazpNXsy1P2V9iupwr+CI/Q5jxASLeMXIHnpyNAAAAAElFTkSuQmCC")
	signature_edit()

func signature_edit():
	var edit = preload("res://addons/cards/signature/signature_edit.tscn").instantiate()
	edit.on_edit.connect(func (s): signature = s)
	edit.signature = signature
	ui(edit)

func can_edit(): return false

func setup_finished():
	super.setup_finished()
	incoming_connected(null)

func get_out_signatures(list: Array, visited = []):
	if not parent: list.push_back(signature)
	else: list.append_array(signature.make_concrete(_get_incoming_list(), visited))

func _get_incoming_list():
	return parent.get_incoming() if parent else []

func get_concrete_signatures(visited = []):
	var l = [] as Array[Signature]
	get_out_signatures(l, visited)
	return l

func _get_remembered_for(signature: Signature):
	if not parent: return null
	for card in parent.get_all_incoming():
		if is_valid_incoming(card, signature):
			var val = get_remembered_for(card, signature)
			if val: return val
	return null

func is_valid_incoming(card, signature):
	return true
	# FIXME this needed?
	#var s = []
	#card.get_out_signatures(s)
	#for sig in s:
		#if signature_match(sig, signature): return true
	#return false

func get_remembered():
	return _get_remembered_for(signature)

func get_connected_incoming(visited = []):
	var connected = []
	var my_signatures = get_concrete_signatures(visited)
	for c in _get_incoming_list():
		var out = [] as Array[Signature]
		get_object_out_signatures(c, out, visited)
		for their_signature in out:
			for my_signature in my_signatures:
				if their_signature.compatible_with(my_signature):
					connected.push_back(s)
					break
	return connected

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	for card in get_outgoing():
		card.invoke(args, signature, "", out_card)
	for name in named_outgoing:
		for p in named_outgoing[name]:
			var card = get_node_or_null(p)
			if card: card.invoke(args, signature, name, out_card)

## An incoming connection from [obj] was established. [obj] is [null]
## when this is called from the initialization of pre-existing connections.
func incoming_connected(obj: Node):
	for card in get_all_outgoing():
		for input in card.cards:
			if input is InCard: input.incoming_connected(obj)

func incoming_disconnected(obj: Node):
	for card in get_all_outgoing():
		for input in card.cards:
			if input is InCard: input.incoming_disconnected(obj)

func try_connect_in(them: Node):
	if not parent: return
	if parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	var my_signatures = get_concrete_signatures()
	for card in Card.get_object_cards(them):
		if card is OutCard:
			var their_signatures = [] as Array[Signature]
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				for my_signature in my_signatures:
					if their_signature.compatible_with(my_signature):
						connect_to(them, parent if parent else self)
						incoming_connected(them)
						return

func detect_cycles_for_new_connection(from: Card, to: Card) -> bool:
	if (to.allows_cycles() or from.allows_cycles()) and not from.get_all_outgoing().has(to) and not to.get_all_incoming().has(from):
		return false
	# we never allow direct cycles
	if from.get_all_outgoing().has(to): return true
	if should_allow_connection(from, to): return false
	return check_is_connected(from, to)

func should_allow_connection(from: Card, to: Card):
	return false

func check_is_connected(a: Card, b: Card) -> bool:
	var queue = [a]
	var visitited = {}
	while not queue.is_empty():
		var node: Card = queue.pop_front()
		visitited[node] = true
		for next in node.get_outgoing():
			if not visitited.has(next) and not next.allows_cycles():
				if next == b: return true
				queue.push_back(next)
		for next in node.get_named_outgoing_for_cycles():
			if not visitited.has(next) and not next.allows_cycles():
				if next == b: return true
				queue.push_back(next)
	return false

func serialize_constructor():
	if signature is Signature.TriggerSignature:
		return "{0}.trigger()".format([get_card_name()])
	else:
		return "{0}.data({1})".format([get_card_name(), signature.serialize_gdscript()])
