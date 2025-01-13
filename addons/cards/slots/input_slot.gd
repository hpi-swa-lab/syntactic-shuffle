@tool
extends Slot
class_name InputSlot

## Provide an input from another card's output.

var signatures: Dictionary[String, Array]

func get_slot_name():
	return "__input"

func _init(signatures: Dictionary[String, Array]):
	self.signatures = signatures

func invoke(signature: Array, args: Array):
	for s in signatures:
		if signatures_match(signatures[s], signature):
			if signatures[s] == ["*"]:
				card.generic_called(s, args)
			else:
				card.callv(s, args)
			return
	push_error("no matching signature found on input")

func can_connect_to(object: Node, slot: Slot):
	if not slot is OutputSlot: return false
	for my_signature_name in signatures:
		for their_signature_name in slot.signatures:
			if signatures_match(signatures[my_signature_name], slot.signatures[their_signature_name]):
				return true
	return false
