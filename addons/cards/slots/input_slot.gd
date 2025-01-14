@tool
extends Slot
class_name InputSlot

## Provide an input from another card's output.

var signatures: Dictionary[String, Array]
var is_generic = false

func get_slot_name():
	return "__input"

func _init(signatures: Dictionary[String, Array]):
	self.signatures = signatures
	if signatures.size() == 1 and signatures[signatures.keys()[0]] == ["*"]:
		is_generic = true

func resolve_signatures():
	if is_generic:
		for info in card.connections[get_slot_name()]:
			var them = card.get_node_or_null(info[0])
			if them: return Card.node_get_slot_by_name(them, info[1]).resolve_signatures()
	return signatures

func invoke(signature: Array, args: Array):
	for s in signatures:
		if signatures_match(signatures[s], signature):
			if signatures[s] == ["*"]:
				card.generic_called(signature, args)
			else:
				card.callv(s, args)
			return
	push_error("no matching signature found on input")

func can_connect_to(object: Node, slot: Slot):
	if not slot is OutputSlot: return false
	var my_signatures = resolve_signatures()
	var their_signatures = slot.resolve_signatures()
	for my_signature_name in my_signatures:
		for their_signature_name in their_signatures:
			if signatures_match(my_signatures[my_signature_name], their_signatures[their_signature_name]):
				return can_connect_to_multiple() or not has_closer_connection_than(object)
	return false

func can_connect_to_multiple():
	return not is_generic

func on_connect(object: Node, slot: Slot):
	super.on_connect(object, slot)
	if not can_connect_to_multiple():
		delete_all_connections_but(object)
	if is_generic:
		check_output_still_valid()

func check_output_still_valid():
	var my_signatures = resolve_signatures()
	var output_slot = card.get_slot_by_name("__output")
	for info in card.connections["__output"].duplicate():
		var them = card.get_node_or_null(info[0])
		if not them: continue
		var their_slot = Card.node_get_slot_by_name(them, info[1])
		_check_one_output(output_slot, my_signatures, them, their_slot)

func _check_one_output(output_slot, my_signatures, them, their_slot):
	var their_signatures = their_slot.resolve_signatures()
	for my_signature_name in my_signatures:
		for their_signature_name in their_signatures:
			if not signatures_match(my_signatures[my_signature_name], their_signatures[their_signature_name]):
				Card.node_disconnect_slot(card, output_slot, them, Card.node_get_slot_by_name(them, their_slot.get_slot_name()))
				Card.node_disconnect_slot(them, Card.node_get_slot_by_name(them, their_slot.get_slot_name()), card, output_slot)
				return
