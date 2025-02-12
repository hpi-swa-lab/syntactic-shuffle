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

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	# direct triggers are also considered for connection
	# TODO need to make sure we also disconnect
	super.invoke(args, cmd("connect", signature), named, source_out)

func signature_changed():
	super.signature_changed()
	if out_card: out_card.signature = signature
	if disconnect_card: disconnect_card.signature = signature

func _trigger(command: String, obj: Card):
	var remembered = obj.get_remembered_for(signature) if obj else get_remembered()
	if remembered: super.invoke(remembered.get_remembered_value(), cmd(command, signature))

func propagate_incoming_connected(seen):
	super.propagate_incoming_connected(seen)
	seen[self] = &"notify_done"

func notify_done_propagate():
	_trigger("connect", null)

func incoming_connected(obj: Card):
	_trigger("connect", obj)
	super.incoming_connected(obj)

func incoming_disconnected(obj: Card):
	_trigger("disconnect", obj)
	super.incoming_disconnected(obj)

func serialize_constructor():
	return "{0}.new({1})".format([card_name, signature.serialize_gdscript()])
