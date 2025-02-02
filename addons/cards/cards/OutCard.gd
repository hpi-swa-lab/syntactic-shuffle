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

var remembered
var remembered_signature

## Check if we have a compatible remembered value. If we remember values
## in general but we don't currently a value, check our incoming connections.
func _get_remembered_for(signature: Signature):
	if not remember_message: return null
	
	if remembered_signature and get_remembered_value():
		if remembered_signature.compatible_with(signature): return self
		else: return null
	else: return _try_connected_remembered(signature)

func get_remembered_value():
	assert(remembered != null)
	for arg in remembered:
		# guard against freed objects to which we remember references
		if not is_instance_valid(arg) and typeof(arg) == TYPE_OBJECT:
			remembered_signature = null
			remembered = null
	return remembered

func _try_connected_remembered(signature: Signature):
	for card in get_all_incoming():
		var r = get_remembered_for(card, signature)
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

func get_out_signatures(signatures: Array[Signature]):
	if not is_reachable(): return
	
	if has_static_signature:
		signatures.push_back(_add_command(signature))
		return
	var incoming = get_incoming()
	if incoming.is_empty(): return
	
	for i in incoming:
		if command_name:
			var list = []
			get_object_out_signatures(i, list)
			for item in list: signatures.push_back(_add_command(item))
		else:
			get_object_out_signatures(i, signatures)

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	if Engine.is_editor_hint(): return
	
	if command_name: signature = _add_command(signature)
	
	if has_static_signature:
		if not signature.compatible_with(self.signature): return
		signature = self.signature
	
	if remember_message:
		remembered_signature = signature
		remembered = args
	
	if source_out: mark_activated(source_out)
	
	var n = get_object_named_outgoing(parent)
	for name in n:
		for p in n[name]:
			var obj = parent.get_node_or_null(p)
			if obj: obj.invoke(args, signature, name, self)
	for out in get_object_outgoing(parent):
		var obj = parent.get_node_or_null(out)
		if obj: obj.invoke(args, signature, named, self)

## Check if this OutCard is connected to an InCard that could currently
## receive input (since its parent is connected to a card of a matching
## signature). Note that if the parent has no connected cards, we assume
## all cards to be reachable.
## The method over-approximates the answer: as soon as at least one input
## of a connected component is reachable, it answers true.
func is_reachable():
	if not parent is Card or parent.get_all_incoming().is_empty(): return true
	# CodeCard out's are not connected
	if parent is CodeCard: return true
	
	var inputs = []
	get_connected_inputs(inputs, {})
	for input in inputs:
		if not input.get_connected_incoming().is_empty():
			return true
	return false

func serialize_constructor():
	if command_name:
		return "{0}.command(\"{1}\")".format([get_card_name(), command_name])
	elif remember_message:
		return "{0}.remember()".format([get_card_name()])
	elif has_static_signature:
		return "{0}.static_signature({1}, {2})".format([get_card_name(), signature.serialize_gdscript(), remember_message])
	else:
		return "{0}.new()".format([get_card_name()])
