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

static func create_default():
	return InCard.new(t(""))

func clone():
	return get_script().new(signature)

var signature: Signature = Signature.VoidSignature.new():
	get: return signature
	set(v):
		signature = v
		signature_changed()
var out_card
var actual_signatures: Array[Signature] = []

func s():
	# special InCard that the OutCard uses for connection purposes. Would yield
	# an infinite loop if we proceeded here.
	if signature is Signature.OutputAnySignature: return
	
	out_card = StaticOutCard.new("out", signature)

func v():
	title("Input")
	description("Receive input.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAKFJREFUOI3FUjESwzAIE71OWfhCPff/T2F2vsCSlS6Oiznj5LpUi+/AQoAA/glhBiU5S+L9vzCPgUBeFaaTDACPjFznXVDszit1sjBjUzX/52iqmyoKYMJMAECJ0ky5owBWWyyOkCEVuVsgxd0CmSt4lm9ysOhc4suMdprzj8khRRspEt6q3YGstYFY21tazpNXsy1P2V9iupwr+CI/Q5jxASLeMXIHnpyNAAAAAElFTkSuQmCC")
	signature_edit()

func signature_edit():
	var edit = preload("res://addons/cards/signature/signature_edit.tscn").instantiate()
	edit.on_edit.connect(func(s): signature = s)
	edit.signature = signature
	ui(edit)

func can_edit(): return false

func signature_changed():
	if parent: # FIXME this fine?
		actual_signatures = _compute_actual_signatures(signature)
	if out_card: out_card.override_signature([signature] as Array[Signature])

func propagate_incoming_connected(seen):
	if parent is OutCard:
		actual_signatures = parent.actual_signatures
	else:
		actual_signatures = _compute_actual_signatures(signature)
	super.propagate_incoming_connected(seen)

## Our parent card was encountered but this InCard was not reachable.
## We still want to set our signature but do not propagate further.
func propagate_unreachable(seen):
	actual_signatures = _compute_actual_signatures(signature)
	super.propagate_unreachable(seen)

func _get_incoming_list():
	return parent.get_incoming() if parent else []

func get_remembered_for(signature: Signature):
	if not parent: return null
	for card in parent.get_all_incoming():
		if is_valid_incoming(card, signature):
			var val = card.get_remembered_for(signature)
			if val: return val
	return null

func is_valid_incoming(card, signature):
	return true
	# FIXME this needed?
	#for sig in card.output_signatures:
		#if signature_match(sig, signature): return true
	#return false

func get_inputs() -> Array[Card]: return [self] as Array[Card]

func get_remembered():
	return get_remembered_for(signature)

func has_connected():
	# NOTE: cannot use self.actual_signatures here since since is used during the
	# forward pass in propagate_input_connected
	for c in _get_incoming_list():
		if c.output_signatures.any(func(s): return s.compatible_with(signature)): return true
	return false

func invoke(args: Array, signature: Signature, invocation: Invocation, named = "", source_out = null):
	for card in get_outgoing():
		card.invoke(args, signature, invocation, "", out_card)
	for name in named_outgoing:
		for p in named_outgoing[name]:
			var card = lookup_card(p)
			if card: card.invoke(args, signature, invocation, name, out_card)

func try_connect_in(them: Card):
	if not parent: return
	if parent.get_incoming().has(them): return
	if detect_cycles_for_new_connection(parent, them): return
	
	var my_signatures = actual_signatures
	for card in them.cards:
		if card is OutCard:
			for their_signature in card.output_signatures:
				for my_signature in my_signatures:
					if their_signature.compatible_with(my_signature):
						them.connect_to(parent if parent else self)
						get_editor().card_connected(them, self)
						incoming_connected(them)
						return

func detect_cycles_for_new_connection(from: Card, to: Card) -> bool:
	if (to.allows_cycles or from.allows_cycles) and not from.get_all_outgoing().has(to) and not to.get_all_incoming().has(from):
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
			if not visitited.has(next) and not next.allows_cycles:
				if next == b: return true
				queue.push_back(next)
		for next in node.get_named_outgoing_for_cycles():
			if not visitited.has(next) and not next.allows_cycles:
				if next == b: return true
				queue.push_back(next)
	return false

func serialize_constructor():
	if signature is Signature.TriggerSignature:
		return "{0}.trigger()".format([card_name])
	else:
		return "{0}.data({1})".format([card_name, signature.serialize_gdscript()])
