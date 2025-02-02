@tool
extends Node

var values = {}

func put(name: String, value: Variant):
	values[name] = value

func at(name: String):
	return values[name]

static func has_parent(node: Node, parent: Node):
	while node:
		node = node.get_parent()
		if node == parent:
			return true
	return false

static func or_default(value: Variant, cb: Callable, default = null):
	if value: return cb.call(value)
	return default

static func traverse_nodes(parent: Node, exclude: Array[Node], cb: Callable):
	if exclude.has(parent):
		return
	cb.call(parent)
	for child in parent.get_children():
		traverse_nodes(child, exclude, cb)

static func distance_to_node(point: Vector2, node: Node):
	if node is CanvasItem:
		return point.distance_to(global_rect_of(node).get_center())
	else:
		return INF

static func global_rect_of(node: Node, depth: int = 0, excluded: Array = []) -> Rect2:
	if not node is CanvasItem:
		return Rect2(0, 0, 0, 0)
	
	node = closest_parent_with_position(node)
	var rect = Rect2(node.global_position, Vector2.ZERO)
	#if node is PlaceholderBehavior or node is HealthBarBehavior:
	#	rect = Rect2(node.global_position - node.size / 2, node.size)
	if "size" in node:
		rect = Rect2(node.global_position, node.size)
	elif "shape" in node and node.shape:
		var s = node.shape.get_rect().size
		rect = Rect2(node.global_position - s / -2, s)
	elif "get_rect" in node:
		rect = node.global_transform * node.get_rect()

	if depth == 0:
		return rect
	
	return node.get_children() \
		.filter(func(child): return child not in excluded and child is Node2D) \
		.map(func(child): return global_rect_of(child, depth - 1, excluded)) \
		.reduce(func(a, b): return a.merge(b), rect)

static func closest_parent_with_position(node: Node) -> Node:
	return closest_parent_that(node, Callable(G, 'has_position'))

static func has_position(node: Node) -> bool:
	return "global_position" in node

static func closest_parent_that(node: Node, cond: Callable) -> Node:
	while node != null:
		if cond.call(node):
			return node
		node = node.get_parent()
	return null

func eval_expression(code: String):
	return eval_object("extends Object\nfunc build():\n\treturn {0}".format([code])).build()

func eval_object(code: String, instance_object = null):
	var s = GDScript.new()
	s.source_code = code
	if s.reload() != OK:
		return null
	var obj = instance_object.call() if instance_object else Object.new()
	obj.set_script(s)
	return obj
