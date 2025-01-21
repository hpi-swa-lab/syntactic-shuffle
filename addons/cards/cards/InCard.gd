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

func setup_finished():
	super.setup_finished()
	incoming_connected(null)

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
		for p in named_outgoing[name]:
			var card = get_node_or_null(p)
			if card: card.invoke(args, signature, name)

func signature_changed(): pass

## An incoming connection from [obj] was established. [obj] is [null]
## when this is called from the initialization of pre-existing connections.
func incoming_connected(obj: Node):
	for card in get_all_outgoing():
		for input in card.cards:
			if input is InCard: input.incoming_connected(obj)

func incoming_disconnected(obj: Node):
	for card in get_all_outgoing():
		for input in card.cards:
			if input is InCard: input.incoming_disconnected(obj)

func try_connect(them: Node):
	if parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	for card in Card.get_object_cards(them):
		if card is OutCard:
			var their_signatures = [] as Array[Signature]
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if their_signature.compatible_with(signature):
					connect_to(them, parent)
					incoming_connected(them)
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
