@tool
extends Object
class_name Slot

var card: Card

func ready(card: Card):
	self.card = card

func get_slot_name():
	push_error("no slot name configured")

func can_connect_to(object: Node, slot: Slot):
	return false

func on_disconnect(object: Node, slot: Slot):
	pass

func on_connect(object: Node, slot: Slot):
	pass

func draw(draw_node: CardConnectionsDraw):
	pass

func get_draw_dependencies(deps: Array):
	pass

func has_closer_connection_than(object: Node):
	# check if we have a connection that's closer to us already
	for info in card.connections[get_slot_name()]:
		var them = card.get_node_or_null(info[0])
		if them and them.global_position.distance_to(card.global_position) < object.global_position.distance_to(card.global_position):
			return true
	return false

func delete_all_connections_but(object: Node):
	# NOTE: assumes that this is used to ensure a single connection.
	# With this assumption iterate while modify is okay here because we have at most one other connection
	for info in card.connections[get_slot_name()]:
		var them = card.get_node_or_null(info[0])
		if them and them != object:
			Card.node_disconnect_slot(card, self, them, Card.node_get_slot_by_name(them, info[1]))
			Card.node_disconnect_slot(them, Card.node_get_slot_by_name(them, info[1]), card, self)

func draw_connections(draw_node: CardConnectionsDraw, inverted):
	var connections = card.connections[get_slot_name()]
	for info in connections:
		var to = card.get_node_or_null(info[0])
		if to: draw_node.draw_connection(card, to, inverted)

func signatures_match(a: Array, b: Array):
	if a == ["*"]: return true
	if b == ["*"]: return true
	return a == b

func detect_cycles_for_new_connection(from: Card, to: Card) -> bool:
	return check_is_connected(from, to)

func check_is_connected(a: Card, b: Card) -> bool:
	var queue = [a]
	var visitited = {}
	while not queue.is_empty():
		var node: Card = queue.pop_front()
		visitited[node] = true
		for name in node.connections:
			for info in node.connections[name]:
				if info[1] != "__output": continue
				var next = node.get_node_or_null(info[0])
				if next and not visitited.has(next):
					if next == b:
						return true
					queue.push_back(next)
	return false
