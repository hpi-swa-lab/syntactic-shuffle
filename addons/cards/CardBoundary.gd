@tool
extends Area2D
class_name CardBoundary

@export var disable_on_enter = false
@export var layout_cards_in_row = false
@export var horizontal_spacing = 15

func _ready() -> void:
	add_to_group("card_boundary")

static func get_closest_card(card: Card, slot: Slot):
	var boundary = get_card_boundary(card)
	var exclude = card.get_tree().get_nodes_in_group("card_boundary")
	exclude.erase(boundary)
	exclude.push_back(card)
	return G.closest_node(boundary,
		card, func(n, d): return slot.can_connect_to(n), exclude)

static func get_card_boundary(card: Card):
	var b = G.closest_parent_that(card, func (n): return n is CardBoundary)
	if not b:
		return card.get_tree().root
	return b

static func boundary_at_card(card: Card):
	var pos = card.get_canvas_transform() * card.global_position
	var fallback = null
	for boundary in card.get_tree().get_nodes_in_group("card_boundary").filter(func (c): return c.is_visible_in_tree()):
		if boundary.get_shape_owners().is_empty():
			assert(fallback == null, "cannot have multiple fallback card boundaries")
			fallback = boundary
		for id in boundary.get_shape_owners():
			var shape = boundary.shape_owner_get_shape(id, 0)
			var rect = boundary.shape_owner_get_transform(id) * shape.get_rect()
			rect = boundary.get_canvas_transform() * rect
			if rect.has_point(pos):
				return boundary
	return fallback

static func card_moved(card: Card):
	var boundary = boundary_at_card(card)
	if get_card_boundary(card) != boundary:
		card.reparent(boundary)
		card.global_position = boundary.get_global_mouse_position()
		card.disable = boundary.disable_on_enter

func card_picked_up(card: Card):
	pass

func card_dropped(card: Card):
	if layout_cards_in_row:
		_relayout()

func background_rect() -> Rect2:
	for id in get_shape_owners():
		var shape = shape_owner_get_shape(id, 0)
		return shape_owner_get_transform(id) * shape.get_rect()
	return Rect2()

func _relayout():
	var background = background_rect()
	var left = horizontal_spacing + background.position.x
	for card in get_children().filter(func (s): return s is Card):
		var extent = card.get_extent()
		var new_position = Vector2(left + extent.x / 2, background.position.y + background.size.y / 2)
		var tween = get_tree().create_tween()
		tween\
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.tween_property(card, "position", new_position, 0.25)
		left += extent.x + horizontal_spacing
