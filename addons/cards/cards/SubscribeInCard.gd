@tool
extends InCard
class_name SubscribeInCard

static func create(signature: Signature):
	var c = SubscribeInCard.new(signature)
	return c

var disconnect_card: OutCard

func can_edit(): return false

func v():
	title("Subscribe Input")
	description("Trigger when an input is connected and when it's disconnected.")
	icon(preload("res://addons/cards/icons/forward.png"))
	signature_edit()

func s():
	out_card = StaticOutCard.new("connect", cmd("connect", signature))
	disconnect_card = StaticOutCard.new("disconnect", cmd("disconnect", signature))

var _signaled_for = {}

func invoke(args: Array, signature: Signature, invocation: Invocation, named = "", source_out = null):
	# direct triggers are also considered for connection
	if _signaled_for.has(source_out.parent):
		_trigger("disconnect", source_out.parent, invocation)
	_signaled_for[source_out.parent] = args[0]
	super.invoke(args, cmd("connect", signature), invocation, named, source_out)

func signature_changed():
	super.signature_changed()
	if out_card: out_card.signature = signature
	if disconnect_card: disconnect_card.signature = signature

func _trigger(command: String, card: Card, invocation: Invocation):
	var remembered = card.get_remembered_for(signature, invocation) if card else get_remembered(invocation)
	if remembered:
		var val = remembered.get_remembered_value(invocation)
		if command == "connect": _signaled_for[card] = val[0]
		super.invoke(val, cmd(command, signature), invocation)

func propagate_incoming_connected(seen):
	var init = not initialized_signatures
	super.propagate_incoming_connected(seen)
	if init: seen[self] = &"notify_done"

func notify_done_propagate():
	_trigger("connect", null, Invocation.new())

func incoming_connected(card: Card):
	if _signaled_for.has(card):
		super.invoke([_signaled_for[card]], cmd("disconnect", signature), Invocation.new())
		_signaled_for.erase(card)
	_trigger("connect", card, Invocation.new())
	super.incoming_connected(card)

func incoming_disconnected(card: Card):
	if _signaled_for.has(card):
		super.invoke([_signaled_for[card]], cmd("disconnect", signature), Invocation.new())
		_signaled_for.erase(card)
	super.incoming_disconnected(card)

func serialize_constructor():
	return "{0}.new({1})".format([card_name, signature.serialize_gdscript()])
