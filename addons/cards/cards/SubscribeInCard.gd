@tool
extends InCard
class_name SubscribeInCard

static func create(signature: Signature):
	var c = SubscribeInCard.new()
	c.signature = signature
	return c

func s():
	title("Subscribe Input")
	description("Trigger when an input is connected and when it's disconnected.")
	icon(preload("res://addons/cards/icons/forward.png"))

func incoming_connected(obj: Node):
	var remembered = get_remembered_for(obj, signature) if obj else get_remembered()
	if remembered: invoke(remembered.get_remembered_value(), cmd("connect", signature))

func incoming_disconnected(obj: Node):
	invoke([obj], cmd("disconnect", signature))
