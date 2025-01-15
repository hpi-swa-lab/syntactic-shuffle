extends InputSlot
class_name NamedInputSlot

var name: String

func get_slot_name():
	return name

func _init(name: String, signatures: Dictionary[String, Array]) -> void:
	super._init(signatures)
	self.name = name

func can_connect_to(object: Node, slot: Slot):
	if not super.can_connect_to(object, slot):
		return false
	
	var pair = [card.get_path_to(object), slot.get_slot_name()]
	var we_are_connected = not card.connections[get_slot_name()].is_empty()
	for name in card.connections:
		# we connect named input slots one by one, so first check
		# if there is already a connection from this slot to us
		if card.connections[name].has(pair):
			return false
		# then check if there is another named slot that we can connect first
		if we_are_connected and (card.get_slot_by_name(name) is NamedInputSlot and
			card.connections[name].is_empty()):
			return false
	return true

func can_connect_to_multiple():
	return false

func draw(draw_node: CardConnectionsDraw):
	for info in card.connections[get_slot_name()]:
		var obj = card.get_node_or_null(info[0])
		if obj: draw_node.draw_label_to(obj, get_slot_name())

func get_draw_dependencies(deps: Array):
	var connections = card.connections[get_slot_name()]
	deps.push_back(card.global_position)
	for info in connections:
		var to = card.get_node_or_null(info[0])
		if to: deps.push_back(to.global_position)
