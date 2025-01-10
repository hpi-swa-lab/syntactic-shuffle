@tool
extends Node

var values = {}

func put(name: String, value: Variant):
	values[name] = value

func at(name: String):
	return values[name]

static func closest_node(node: Node, filter: Callable):
	var data = { "best_distance": INF }
	var pos = node.global_position
	var candidate = all_nodes_reduce(null, node.get_viewport(), [node], func(current, test):
		var distance = G.distance_to_node(pos, test)
		if filter.call(test, distance) and (not current or distance < data["best_distance"]):
			data["best_distance"] = distance
			return test
		else: return current)
	return candidate

static func or_default(value: Variant, cb: Callable, default = null):
	if value: return cb.call(value)
	return default

static func all_nodes_reduce(init: Variant, parent: Node, exclude: Array[Node], cb: Callable):
	if exclude.has(parent):
		return init
	init = cb.call(init, parent)
	for child in parent.get_children():
		init = all_nodes_reduce(init, child, exclude, cb)
	return init

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
