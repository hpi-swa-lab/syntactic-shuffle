@tool
extends Card
class_name NodeCard

var node: Node

func _init(node):
	self.node = node
	super._init()
	# We are never shown, so we need to trigger signature discovery manually
	node.ready.connect(func(): start_propagate_incoming_connected(true), CONNECT_ONE_SHOT)

func can_edit(): return false

func get_card_global_position(): return node.global_position

func lookup_card(path: NodePath): return node.get_node_or_null(path)

func is_offscreen(): return true

func v():
	title("Node Proxy")
	description("A standin for a node in the scene.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAHdJREFUOI3dUjEKwCAQi6V/08G+th30dekgHloMFRwKzXKYCyFGga/hBM9Z/a6co/fd+cp5qNuUwZlSNxWkwSoYvSdJmxC9OLWYxQaUwkiCpJXXciXAWAcAFrWNW1F5dS17xmfbRwgd75z6Mi8J6q5N0HLLJf4AN3DOhmgmhQv2AAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var c = StaticOutCard.new("type", t(node.get_class()), true)
	c.remember(c.static_signature, [node])
	
	var c2 = StaticOutCard.new("group", grp(node.get_groups()), true)
	c2.remember(c2.static_signature, [node])
