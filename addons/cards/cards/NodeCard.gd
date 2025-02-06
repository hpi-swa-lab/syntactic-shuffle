@tool
extends Card
class_name NodeCard

var node: Node

func _init(node):
	self.node = node
	super._init()

func get_card_global_position():
	return node.global_position

func v():
	title("Node Proxy")
	description("A standin for a node in the scene.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAHdJREFUOI3dUjEKwCAQi6V/08G+th30dekgHloMFRwKzXKYCyFGga/hBM9Z/a6co/fd+cp5qNuUwZlSNxWkwSoYvSdJmxC9OLWYxQaUwkiCpJXXciXAWAcAFrWNW1F5dS17xmfbRwgd75z6Mi8J6q5N0HLLJf4AN3DOhmgmhQv2AAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var c = OutCard.static_signature(t(node.get_class()), true)
	c.remembered = [node]
	c.remembered_signature = c.signature
	
	OutCard.static_signature(grp(node.get_groups()), true)
