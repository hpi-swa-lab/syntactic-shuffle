@tool
extends Slot
class_name OutputSlot

## Provide an output from a card, to be used by an [InputSlot].

var signatures: Dictionary[String, Array]
var is_generic = false

func get_slot_name():
	return "__output"

func _init(signatures: Dictionary[String, Array]):
	self.signatures = signatures
	if signatures.size() == 1 and signatures[signatures.keys()[0]] == ["*"]:
		is_generic = true

func resolve_signatures():
	if is_generic: return card.get_slot_by_name("__input").resolve_signatures()
	else: return signatures

func can_connect_to(object: Node, slot: Slot):
	if not slot is InputSlot: return false
	return slot.can_connect_to(card, self)
	#var my_signatures = resolve_signatures()
	#var their_signatures = slot.resolve_signatures()
	#for my_signature_name in my_signatures:
		#for their_signature_name in their_signatures:
			#if signatures_match(my_signatures[my_signature_name], their_signatures[their_signature_name]):
				#return true
	#return false

func invoke(signature_name: String, args: Array):
	var signature = resolve_signatures()[signature_name]
	invoke_signature(signature, args)

func invoke_signature(signature: Array, args: Array):
	for connected in card.connections[get_slot_name()]:
		var them = card.get_node_or_null(connected[0])
		if not them: continue
		var slot_name = connected[1]
		var their_slot = them.get_slot_by_name(slot_name)
		their_slot.invoke(signature, args)
		card.connection_draw_node.on_activated(them)

func draw(draw_node):
	draw_connections(draw_node, false)

func get_draw_dependencies(deps: Array):
	var connections = card.connections[get_slot_name()]
	deps.push_back(card.global_position)
	for info in connections:
		var to = card.get_node_or_null(info[0])
		if to: deps.push_back(to.global_position)
