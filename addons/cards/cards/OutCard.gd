@tool
extends Card
class_name OutCard

func _init(remember = false) -> void:
	self.remember_message = remember
	super._init()

var remember_message := false
var actual_signatures: Array[Signature] = []

var remembered: Dictionary[Invocation, Invocation.Remembered]

func get_outputs() -> Array[Card]: return [self] as Array[Card]

func _get_base_signatures():
	# if we have no connections, we advertise all possibilities.
	if _get_incoming_list().is_empty():
		return [Signature.OutputAnySignature.new()]
	# Otherwise, we pass null, which makes us inherit our incoming signatures.
	return []

func _get_aggregate(): return false

func _get_incoming_list():
	# OutCards in a CodeCard are not connected to their inputs
	# TODO consider generic type names
	if parent is CodeCard: return parent.cards.filter(func(c): return c is InCard)
	if parent is InCard: return [StubCard.new(parent)]
	return get_all_incoming()

class StubCard:
	var c
	func _init(c): self.c = c
	var output_signatures:
		get: return c.actual_signatures if c.has_connected() else []

func propagate_incoming_connected(seen):
	var sig = _get_base_signatures()
	var aggregate = _get_aggregate()
	actual_signatures = [] as Array[Signature]
	for s in sig: actual_signatures.append_array(_compute_actual_signatures(s, aggregate))
	if sig.is_empty(): actual_signatures.append_array(_compute_actual_signatures(Signature.OutputAnySignature.new(), aggregate))
	super.propagate_incoming_connected(seen)

func propagate_unreachable(seen):
	if seen.has(self): return
	initialized_signatures = true
	seen[self] = &"unreachable"
	# If no connected is reachable, show no signatures
	actual_signatures = []

## Check if we have a compatible remembered value. If we remember values
## in general but we don't currently a value, check our incoming connections.
func get_remembered_for(signature: Signature, invocation: Invocation):
	var r = _remembered_for_invocation(invocation)
	if r and r.valid():
		if r.signature.compatible_with(signature): return self
		else: return null
	else: return _try_connected_remembered(signature, invocation)

func get_remembered_value(invocation):
	return _remembered_for_invocation(invocation).args

func get_remembered_signature(invocation):
	return _remembered_for_invocation(invocation).signature

func _try_connected_remembered(signature: Signature, invocation: Invocation):
	for card in get_all_incoming():
		var r = card.get_remembered_for(signature, invocation)
		if r: return r
	return null

func _remembered_for_invocation(invocation: Invocation) -> Invocation.Remembered:
	var r = remembered.get(invocation)
	if r: return r
	return remembered.get(Invocation.GLOBAL)

func get_remembered_for_display():
	for s in output_signatures:
		var r = get_remembered_for(s, Invocation.GLOBAL)
		if r: return r.get_remembered_value(Invocation.GLOBAL)
	return null

func s():
	InCard.data(Signature.OutputAnySignature.new())

func v():
	title("Output")
	description("Emit output.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIZJREFUOI3FUjsOwCAIBdOlEwfx/kfxIEzdtJMEVNB06ZsMvA8RAP5EIQJ0es2pC78Q2cIgjoyxi1cGkbgnG44mS0MnOFOI9lokaNLOCNMBMTSZJui4a5X3k/wc1yASKaBnEG3CfKKOQQBomRky86Qaass16gT3kAqR6X065egSj7E5tnOTFy92Ir2sNy07AAAAAElFTkSuQmCC")

func remember(signature: Signature, args: Array, invocation: Invocation):
	assert(remember_message)
	remembered[invocation] = invocation.remember(signature, args)

func invoke(args: Array, signature: Signature, invocation: Invocation, named = "", source_out = null):
	if not parent: return
	if Engine.is_editor_hint(): return
	
	if remember_message: remember(signature, args, invocation)
	if source_out: mark_activated(source_out, args)
	
	var n = parent.named_outgoing
	_feedback_signaled = false
	for name in n:
		for p in n[name]:
			var obj = parent.lookup_card(p)
			if obj: obj.invoke(args, signature, invocation.pop(), name, self)
	for out in parent.outgoing:
		var obj = parent.lookup_card(out)
		if obj: obj.invoke(args, signature, invocation.pop(), named, self)
	
	if not _feedback_signaled: parent.show_feedback_for(null, args)

var _feedback_signaled = false

func mark_signaled_feedback():
	_feedback_signaled = true

func serialize_constructor():
	return "{0}.new({1})".format([card_name, remember_message])
