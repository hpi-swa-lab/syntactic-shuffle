@tool
extends Card
class_name MagnetCard

var _proxied_object: Node
@export var proxied_object: NodePath:
	get: return proxied_object
	set(v):
		if _proxied_object: _proxied_object.tree_exiting.disconnect(on_exit)
		proxied_object = v
		_proxied_object = get_node_or_null(v)
		if _proxied_object: _proxied_object.tree_exiting.connect(on_exit)

func on_exit():
	var connections = Card.node_get_connections(_proxied_object)
	for name in connections:
		for info in connections[name]:
			var them = get_node_or_null(info[0])
			if not them: continue
			var their_slot = Card.node_get_slot_by_name(them, info[1])
			var my_slot = Card.node_get_slot_by_name(_proxied_object, name)
			Card.node_disconnect_slot(_proxied_object, my_slot, them, their_slot)
			# on their side, the stored connection is to the magnet, not to the proxied object.
			# only through the various overriden dispatches, we expose the proxied object.
			Card.node_disconnect_slot(them, their_slot, self, my_slot)
	proxied_object = NodePath()

func _get_connections() -> Dictionary[String, Array]:
	var obj = get_proxied()
	if obj: return Card.node_get_connections(obj)
	else: return {} as Dictionary[String, Array]

func get_proxy_slots() -> Array[Slot]:
	var obj = get_proxied()
	return Card.node_get_slots(obj) if obj else ([] as Array[Slot])

func _get_slots() -> Array[Slot]:
	return get_proxy_slots()

func get_proxied():
	return get_node_or_null(proxied_object)

func _ready() -> void:
	super._ready()
	
	setup("Magnet", "Proxy another card or object from this card.", "magnet.png", CardVisual.Type.Effect, [])
	
	if not _proxied_object and proxied_object:
		_proxied_object = get_node_or_null(proxied_object)
		if _proxied_object: _proxied_object.tree_exiting.connect(on_exit)

#func connect_slot(my_slot: Slot, them: Node, their_slot: Slot):
	#var obj = get_proxied()
	#if obj is Card: super.connect_slot(my_slot, them, their_slot)
#
#func disconnect_slot(my_slot: Slot, them: Node, their_slot: Slot, index: int = -1):
	#var obj = get_proxied()
	#if obj is Card: super.disconnect_slot(my_slot, them, their_slot, index)
