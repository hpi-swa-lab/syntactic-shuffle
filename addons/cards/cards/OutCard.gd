@tool
extends Card
class_name OutCard

static func data():
	return OutCard.new()

static func command(command: String):
	var c = OutCard.new()
	c.command_name = command
	return c

static func remember(init = null, init_signature: Signature = null):
	var c = OutCard.new()
	c.remember_message = true
	if init != null:
		c.remembered = init
		c.remembered_signature = init_signature
	return c

static func remember_command(command: String):
	var c = OutCard.new()
	c.remember_message = true
	c.command_name = command
	return c

static func static_signature(signature: Signature, remember = false):
	var c = OutCard.new()
	c.signature = signature
	c.has_static_signature = true
	c.remember_message = remember
	return c

@export var remember_message := false
@export var command_name := ""
@export var has_static_signature := false
var signature: Signature

var remembered
var remembered_signature

func _get_remembered_for(signature: Signature):
	if remembered_signature and remembered_signature.compatible_with(signature):
		for arg in remembered:
			# guard against freed objects to which we remember references
			if not is_instance_valid(arg) and typeof(arg) == TYPE_OBJECT:
				remembered_signature = null
				remembered = null
				continue
		return self
	return null

func get_remembered_value():
	assert(remembered != null)
	return remembered

func s():
	title("Output")
	description("Emit output.")
	icon("forward.png")

func _add_command(signature: Signature) -> Signature:
	return Signature.CommandSignature.new(command_name, signature)

func get_out_signatures(signatures: Array[Signature]):
	if has_static_signature:
		signatures.push_back(signature)
		return
	var incoming = get_incoming()
	assert(not incoming.is_empty(), "out cards without static signature require connections to infer their signature")
	for i in incoming:
		if command_name:
			var list = []
			i.get_out_signatures(list)
			for item in list: signatures.push_back(_add_command(item))
		else:
			i.get_out_signatures(signatures)

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	if Engine.is_editor_hint(): return
	
	if command_name: signature = _add_command(signature)
	
	if has_static_signature:
		if not signature.compatible_with(self.signature): return
		signature = self.signature
	
	if remember_message:
		remembered_signature = signature
		remembered = args
	
	var n = get_object_named_outgoing(parent)
	for name in n:
		for p in n[name]:
			var obj = parent.get_node_or_null(p)
			obj.invoke(args, signature, name, self)
	for out in get_object_outgoing(parent):
		var obj = parent.get_node_or_null(out)
		obj.invoke(args, signature, named, self)
