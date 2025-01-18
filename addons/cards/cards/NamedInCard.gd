@tool
extends InCard
class_name NamedInCard

static func named_data(name: String, type: String):
	var c = NamedInCard.new()
	c.signature = [type] as Array[String]
	c.input_name = name
	return c

@export var input_name: String

func s():
	title("Named Input")
	description("Receive input via a named connection.")
	icon("forward.png")

func try_connect(them: Card):
	if them.get_outgoing().has(parent): return
	if detect_cycles_for_new_connection(parent, them): return
	
	var named = parent.named_incoming
	for name in named:
		# don't allow us to appear in multiple connections to this input
		if named[name] == them: return
		# only allow one connection to us
		if name == input_name and named[name]: return
	
	for card in them.cards:
		if card is OutCard:
			var their_signatures = []
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if signature_match(signature, their_signature):
					them.connect_to(parent, input_name)
					return
