@tool
extends Card
class_name InCard

static func trigger():
	var c = InCard.new()
	c.signature = trg()
	return c

static func data(signature: Signature):
	var c = InCard.new()
	c.signature = signature
	return c

static func command(command: String, type: Signature = null):
	var c = InCard.new()
	c.signature = cmd(command, type)
	return c

var signature: Signature

func get_out_signatures(list: Array):
	list.push_back(signature)

func s():
	title("Input")
	description("Receive input.")
	icon("forward.png")

func _get_remembered_for(signature: Signature):
	for card in parent.get_all_incoming():
		if is_valid_incoming(card, signature):
			var val = get_remembered_for(card, signature)
			if val: return val
	return null

func is_valid_incoming(card, signature):
	return true
	# FIXME this needed?
	#var s = []
	#card.get_out_signatures(s)
	#for sig in s:
		#if signature_match(sig, signature): return true
	#return false

func get_remembered():
	return _get_remembered_for(signature)

func invoke(args: Array, signature: Signature, named = ""):
	for card in get_outgoing():
		card.invoke(args, signature)
	for name in named_outgoing:
		var card = get_node_or_null(named_outgoing[name])
		if card: card.invoke(args, signature, name)

func signature_changed():
	pass

func try_connect(them: Node):
	if parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	for card in Card.get_object_cards(them):
		if card is OutCard:
			var their_signatures = [] as Array[Signature]
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if signature.compatible_with(their_signature):
					connect_to(them, parent)
					return

func detect_cycles_for_new_connection(from: Card, to: Card) -> bool:
	return check_is_connected(from, to)

func check_is_connected(a: Card, b: Card) -> bool:
	var queue = [a]
	var visitited = {}
	while not queue.is_empty():
		var node: Card = queue.pop_front()
		visitited[node] = true
		for next in node.get_outgoing():
			if not visitited.has(next):
				if next == b: return true
				queue.push_back(next)
		for next in node.get_named_outgoing():
			if not visitited.has(next):
				if next == b: return true
				queue.push_back(next)
	return false
