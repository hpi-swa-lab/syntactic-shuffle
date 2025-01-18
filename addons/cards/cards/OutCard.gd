@tool
extends Card
class_name OutCard

static func data():
	return OutCard.new()

static func command(command: String):
	var c = OutCard.new()
	c.command_name = command
	return c

static func remember():
	var c = OutCard.new()
	c.remember_message = true
	return c

static func remember_command(command: String):
	var c = OutCard.new()
	c.remember_message = true
	c.command_name = command
	return c

static func static_signature(signature: Array[String]):
	var c = OutCard.new()
	c.signature = signature
	c.has_static_signature = true
	return c

@export var remember_message := false
@export var command_name := ""
@export var has_static_signature := false
@export var signature: Array[String] = []

var remembered

func s():
	title("Output")
	description("Emit output.")
	icon("forward.png")

func _add_command(signature: Array[String]):
	var full = [command_name] as Array[String]
	full.append_array(signature)
	return full

func get_out_signatures(signatures: Array):
	if has_static_signature:
		signatures.push_back(signature)
		return
	assert(not incoming.is_empty(), "out cards without static signature require connections to infer their signature")
	for i in incoming:
		if command_name:
			var list = []
			i.get_out_signatures(list)
			for item in list: signatures.push_back(_add_command(item))
		else:
			i.get_out_signatures(signatures)

func invoke(args: Array, signature: Array[String], named = ""):
	if remember_message: remembered = args
	
	if command_name:
		signature = _add_command(signature)
	for out in parent.get_outgoing():
		out.invoke(args, signature)
	var dict = parent.get_named_outgoing()
	for out in dict:
		dict[out].invoke(args, signature, out)

func get_remembered():
	return remembered

func try_connect(them: Card):
	if them.get_incoming().has(parent): return
	
	for card in them.cards:
		if card is InCard:
			var my_signatures = []
			get_out_signatures(my_signatures)
			for my_signature in my_signatures:
				if signature_match(my_signature, card.signature):
					parent.connect_to(them)
					return
