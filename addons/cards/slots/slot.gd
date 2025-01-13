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

func draw(draw_node):
	pass

func get_draw_dependencies(deps: Array):
	pass

func draw_connections(draw_node, inverted):
	var connections = card.connections[get_slot_name()]
	for info in connections:
		var to = card.get_node_or_null(info[0])
		if to: draw_node.draw_connection(card, to, inverted)

func signatures_match(a: Array, b: Array):
	if a == ["*"]: return true
	if b == ["*"]: return true
	return a == b
