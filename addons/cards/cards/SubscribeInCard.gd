@tool
extends InCard
class_name SubscribeInCard

static func create(signature: Signature):
	var c = SubscribeInCard.new(signature)
	return c

var connect_card: OutCard
var disconnect_card: OutCard

func v():
	title("Subscribe Input")
	description("Trigger when an input is connected and when it's disconnected.")
	icon(preload("res://addons/cards/icons/forward.png"))
	signature_edit()

func s():
	out_card = OutCard.static_signature(signature)
	connect_card = OutCard.static_signature(signature)
	connect_card.command_name = "connect"
	disconnect_card = OutCard.static_signature(signature)
	disconnect_card.command_name = "disconnect"

func signature_changed():
	super.signature_changed()
	if connect_card: connect_card.signature = signature
	if disconnect_card: disconnect_card.signature = signature

func incoming_connected(obj: Card):
	var remembered = obj.get_remembered_for(signature) if obj else get_remembered()
	if remembered: invoke(remembered.get_remembered_value(), cmd("connect", signature))

func incoming_disconnected(obj: Card):
	invoke([obj], cmd("disconnect", signature))

func get_out_signatures(list: Array, visited = []):
	var incoming = _get_incoming_list()
	for c in cards: c.get_out_signatures(list, visited)

func serialize_constructor():
	return "{0}.new({1})".format([card_name, signature.serialize_gdscript()])
