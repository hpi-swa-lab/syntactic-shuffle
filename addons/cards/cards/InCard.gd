@tool
extends Card
class_name InCard

static func trigger():
	return InCard.new()

static func data(type: String):
	var c = InCard.new()
	c.signature = [type] as Array[String]
	return c

static func command(command: String, type: String = ""):
	var c = InCard.new()
	if type:
		c.signature = [command, type] as Array[String]
	else:
		c.signature = [command] as Array[String]
	return c

@export var signature: Array[String] = []

class Message:
	var signature: Array[String] = []
	var data := []

var stored_message: Message = null

func get_out_signatures(list: Array):
	list.push_back(signature)

func s():
	title("Input")
	description("Receive input.")
	icon("forward.png")

func invoke(args: Array, signature: Array[String], named = ""):
	for card in get_outgoing():
		card.invoke(args, signature)

func try_connect(them: Card):
	if them.get_outgoing().has(parent): return
	
	for card in them.cards:
		if card is OutCard:
			var their_signatures = []
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if signature_match(signature, their_signature):
					them.connect_to(parent)
					return
