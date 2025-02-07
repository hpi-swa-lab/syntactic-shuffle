@tool
extends Card
class_name OutCard

static func data():
	return OutCard.new()

static func command(command: String):
	var c = OutCard.new(false, null, command)
	return c

static func remember(init = null, init_signature: Signature = null):
	var c = OutCard.new(true)
	if init != null:
		c.remembered = init
		c.remembered_signature = init_signature
	return c

static func remember_command(command: String):
	var c = OutCard.new(true, null, command)
	return c

static func static_signature(signature: Signature, remember = false):
	var c = OutCard.new(remember, signature)
	return c

func _init(remember = false, signature: Signature = null, command = "") -> void:
	self.command_name = command
	self.remember_message = remember
	if signature:
		self.has_static_signature = true
		self.signature = signature
	super._init()

@export var remember_message := false
@export var command_name := ""
@export var has_static_signature := false
var signature: Signature
var actual_signatures: Array[Signature] = []

var remembered
var remembered_signature

func _get_incoming_list():
	# OutCards in a CodeCard are not connected to their inputs
	# TODO consider generic type names
	if parent is CodeCard: return parent.cards.filter(func(c): return c is InCard)
	# InCard's have a special OutCard -- this is us
	if parent is InCard: return [parent]
	return get_all_incoming()

func get_outputs() -> Array[Card]: return [self] as Array[Card]

func propagate_incoming_connected(seen):
	super.propagate_incoming_connected(seen)
	var aggregate = parent is CodeCard and parent.inputs.any(func (pair): return pair[1] is Signature.IteratorSignature)
	# FIXME not sure if we want to wrap an iterator with a command or the other way around
	actual_signatures = Array(
		_compute_actual_signatures(signature if has_static_signature else null, aggregate).map(func (s): return _add_command(s)),
		TYPE_OBJECT,
		&"RefCounted",
		Signature
	)

func propagate_unreachable(seen):
	# If no connected is reachable, show no signatures
	actual_signatures = []

## Check if we have a compatible remembered value. If we remember values
## in general but we don't currently a value, check our incoming connections.
func get_remembered_for(signature: Signature):
	if not remember_message: return null
	
	if remembered_signature and get_remembered_value():
		if remembered_signature.compatible_with(signature): return self
		else: return null
	else: return _try_connected_remembered(signature)

func _ensure_remembered():
	if remembered:
		for arg in remembered:
			# guard against freed objects to which we remember references
			if not is_instance_valid(arg) and typeof(arg) == TYPE_OBJECT:
				remembered_signature = null
				remembered = null

func get_remembered_value():
	_ensure_remembered()
	return remembered

func get_remembered_signature():
	_ensure_remembered()
	return remembered_signature

func _try_connected_remembered(signature: Signature):
	for card in get_all_incoming():
		var r = card.get_remembered_for(signature)
		if r: return r
	return null

func s():
	InCard.data(Signature.OutputAnySignature.new())

func v():
	title("Output")
	description("Emit output.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIZJREFUOI3FUjsOwCAIBdOlEwfx/kfxIEzdtJMEVNB06ZsMvA8RAP5EIQJ0es2pC78Q2cIgjoyxi1cGkbgnG44mS0MnOFOI9lokaNLOCNMBMTSZJui4a5X3k/wc1yASKaBnEG3CfKKOQQBomRky86Qaass16gT3kAqR6X065egSj7E5tnOTFy92Ir2sNy07AAAAAElFTkSuQmCC")

func _add_command(signature: Signature) -> Signature:
	if not command_name: return signature
	if signature is Signature.CommandSignature and signature.command == command_name: return signature
	return Signature.CommandSignature.new(command_name, signature)

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	if Engine.is_editor_hint(): return
	
	if command_name: signature = _add_command(signature)
	
	# FIXME still needed? we now look up the signature in the code card already
	#if has_static_signature:
		#if not signature.compatible_with(self.signature): return
		#signature = self.signature
	
	if remember_message:
		remembered_signature = signature
		remembered = args
	
	if source_out: mark_activated(source_out, args)
	
	var n = parent.named_outgoing
	_feedback_signaled = false
	for name in n:
		for p in n[name]:
			var obj = parent.lookup_card(p)
			if obj: obj.invoke(args, signature, name, self)
	for out in parent.outgoing:
		var obj = parent.lookup_card(out)
		if obj: obj.invoke(args, signature, named, self)
	
	if not _feedback_signaled: parent.show_feedback_for(null, args)

var _feedback_signaled = false

func mark_signaled_feedback():
	_feedback_signaled = true

func serialize_constructor():
	if command_name:
		return "{0}.command(\"{1}\")".format([card_name, command_name])
	elif remember_message:
		return "{0}.remember()".format([card_name])
	elif has_static_signature:
		return "{0}.static_signature({1}, {2})".format([card_name, signature.serialize_gdscript(), remember_message])
	else:
		return "{0}.new()".format([card_name])
