extends Node

var marker: Node2D = null

func register_marker(node: Node2D):
	if marker:
		push_error("Two spawn markers!")
		return
	marker = node

func spawn(node: Node2D):
	marker.get_parent().add_child(node)
