@tool
extends Area2D
class_name CardBoundary

enum Layout {
	NONE,
	ROW,
	FAN
}

@export var disable_on_enter = false
@export var card_layout = Layout.NONE:
	get: return card_layout
	set(v):
		card_layout = v
		_relayout()
@export var card_scale = 0.2

var hovered = false:
	get: return hovered
	set(v):
		if hovered != v:
			hovered = v
			_relayout()

func _ready() -> void:
	add_to_group("card_boundary")
	input_pickable = true

static func traverse_connection_candidates(card: Card, cb: Callable):
	var boundary = get_card_boundary(card)
	var exclude = card.get_tree().get_nodes_in_group("card_boundary")
	exclude.erase(boundary)
	exclude.push_back(card)
	return G.traverse_nodes(boundary, exclude, cb)

static func get_card_boundary(node: Node):
	var b = G.closest_parent_that(node, func (n): return n is CardBoundary)
	if not b:
		return node.get_tree().root
	return b

static func boundary_at_card(card: Card):
	var pos = card.get_viewport().get_mouse_position()
	var fallback = null
	for boundary in card.get_tree().get_nodes_in_group("card_boundary").filter(func (c): return c.is_visible_in_tree()):
		if boundary.get_shape_owners().is_empty():
			assert(fallback == null, "cannot have multiple fallback card boundaries")
			fallback = boundary
		if boundary.contains_screen_position(pos):
			return boundary
	return fallback

static func card_moved(card: Card):
	var boundary = boundary_at_card(card)
	var old_boundary = get_card_boundary(card)
	if old_boundary != boundary:
		card.reparent(boundary)
		card.global_position = boundary.get_global_mouse_position()
		card.disable = boundary.disable_on_enter
		old_boundary._relayout()

func contains_screen_position(pos: Vector2):
	for id in get_shape_owners():
		var shape = shape_owner_get_shape(id, 0)
		var rect = shape_owner_get_transform(id) * shape.get_rect()
		rect = get_canvas_transform() * get_global_transform() * rect
		if rect.has_point(pos):
			return true
	return false

func card_picked_up(card: Card):
	pass

func card_dropped(card: Card):
	_relayout()

func background_rect() -> Rect2:
	for id in get_shape_owners():
		if shape_owner_get_shape_count(id) <= 0: continue
		var shape = shape_owner_get_shape(id, 0)
		return shape_owner_get_transform(id) * shape.get_rect()
	return Rect2()

func _process(delta) -> void:
	hovered = contains_screen_position(get_viewport().get_mouse_position())

func my_card_extent():
	return CardVisual.base_card_size * card_scale

func _relayout():
	match card_layout:
		Layout.ROW: _relayout_row()
		Layout.FAN: _relayout_fan()

func get_cards():
	return get_children().filter(func (s): return s is Card and not s.dragging)

func _apply_card_transform(card: Node2D, new_transform: Transform2D):
	if card.transform != new_transform:
		var tween = get_tree().create_tween()
		tween\
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.tween_property(card, "transform", new_transform, 0.25)

func _relayout_row(spacing = 30, margin_left = 0):
	var horizontal_spacing = spacing * card_scale
	var background = background_rect()
	var left = horizontal_spacing + background.position.x + margin_left
	for card in get_cards():
		var extent = my_card_extent()
		var new_transform = Transform2D(0, Vector2(left + extent.x / 2, background.position.y + background.size.y / 2))
		_apply_card_transform(card, new_transform)
		left += extent.x + horizontal_spacing

var _fan_collision = CollisionShape2D.new()
func _relayout_fan():
	if not hovered:
		if _fan_collision.get_parent(): _fan_collision.get_parent().remove_child(_fan_collision)
		_relayout_row(-my_card_extent().x * 1.6, get_cards().size() * my_card_extent().x * 0.2)
	else:
		const EXTRA_ZOOM = 1.8
		
		# we close the fan when we leave the collision area, so add more collision behind the cards
		var extent = my_card_extent() * EXTRA_ZOOM
		_fan_collision.shape = RectangleShape2D.new()
		_fan_collision.shape.size = Vector2(Vector2(extent.y * 2 + 200, 200 + extent.y))
		_fan_collision.position = Vector2(0, -extent.y / 2)
		if not _fan_collision.get_parent(): add_child(_fan_collision)
		
		# make sure the full rect is on screen
		var rect = _fan_collision.get_canvas_transform() * _fan_collision.get_global_transform() * _fan_collision.shape.get_rect()
		# FIXME also check for bottom / right
		var delta = Vector2.ZERO.max(-rect.position)
		_fan_collision.position += delta
		
		var c = get_cards()
		var i = c.size() / -2
		if c.size() % 2 == 0: i += 0.5
		for card in c:
			var new_transform = Transform2D(i * PI / c.size(), Vector2.ZERO) * Transform2D(0, Vector2(0, -120))
			new_transform = Transform2D(0, delta) * new_transform.scaled(Vector2(EXTRA_ZOOM, EXTRA_ZOOM))
			_apply_card_transform(card, new_transform)
			i += 1
