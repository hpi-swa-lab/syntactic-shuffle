@tool
extends InCard
class_name NamedInCard

static func named_data(name: String, type: String):
	var c = NamedInCard.new()
	if type:
		c.signature = [type] as Array[String]
	else:
		c.signature = [] as Array[String]
	c.input_name = name
	return c

@export var input_name: String

func s():
	title("Named Input")
	description("Receive input via a named connection.")
	icon("forward.png")

func try_connect(them: Node):
	if parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	var named = parent.named_incoming
	var p = parent.get_path_to(them)
	for name in named:
		# don't allow them to appear in multiple connections to us
		if named[name] == p: return
		# only allow one connection to us
		if name == input_name and named[name]: return
	
	for card in get_object_cards(them):
		if card is OutCard:
			var their_signatures = []
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if signature_match(signature, their_signature):
					connect_to(them, parent, input_name)
					return

func _get_remembered_for(signature: Array[String]):
	var card = parent.get_node_or_null(parent.named_incoming[input_name])
	if is_valid_incoming(card, signature):
		var val = get_remembered_for(card, signature)
		if val: return val
	return null
