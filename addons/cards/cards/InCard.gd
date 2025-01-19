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
	if type: c.signature = [command, type] as Array[String]
	else: c.signature = [command] as Array[String]
	return c

@export var signature: Array[String] = []

func get_out_signatures(list: Array):
	list.push_back(signature)

func s():
	title("Input")
	description("Receive input.")
	icon("forward.png")

func invoke(args: Array, signature: Array[String], named = ""):
	for card in get_outgoing():
		card.invoke(args, signature)

func signature_changed():
	pass

func try_connect(them: Node):
	if parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	for card in Card.get_object_cards(them):
		if card is OutCard:
			var their_signatures = []
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if signature_match(signature, their_signature):
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
		for name in node.named_outgoing:
			var next = node.named_outgoing[name]
			if next and not visitited.has(next):
				if next == b: return true
				queue.push_back(next)
	return false
