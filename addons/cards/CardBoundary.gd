@tool
extends Area2D
class_name CardBoundary

enum Layout {
	NONE,
	ROW,
	COLLAPSED_ROW,
	FAN
}

@export var disable_on_enter = false
@export var pause_on_enter = false
@export var light_background = false
@export var card_layout = Layout.NONE:
	get: return card_layout
	set(v):
		card_layout = v
		_extra_collision.shape = null
		_relayout()
@export var card_scale = 0.2
@export var duplicate_on_drag = false
@export var id: String

# we close the expanded view when we leave the collision area, so add more collision behind the cards when expanded
var _extra_collision = CollisionShape2D.new()

var hovered = false:
	get: return hovered
	set(v):
		if hovered != v:
			hovered = v
			_extra_collision.disabled = not hovered
			_relayout()

func _ready() -> void:
	add_to_group("card_boundary")
	input_pickable = true
	_extra_collision.disabled = true
	Card.set_ignore_object(_extra_collision)
	add_child(_extra_collision)
	if not id:
		id = uuid.v4()

static func traverse_connection_candidates(card: Card, cb: Callable):
	var boundary = get_card_boundary(card)
	var exclude = card.get_tree().get_nodes_in_group("card_boundary")
	exclude.erase(boundary)
	exclude.push_back(card)
	return G.traverse_nodes(boundary, exclude, cb)

static func get_card_boundary(node: Node):
	var b = G.closest_parent_that(node, func(n): return n is CardBoundary)
	assert(b, "card was not inside a boundary")
	return b

static func boundary_at_card(card: Card): return boundary_at_position(card.get_viewport().get_mouse_position(), card)
static func boundary_at_position(pos: Vector2, ignore_parent = null):
	#var intersect = PhysicsPointQueryParameters2D.new()
	#intersect.collide_with_areas = true
	#intersect.collide_with_bodies = false
	#intersect.position = card.get_global_mouse_position()
	#var candidates = card.get_world_2d().direct_space_state.intersect_point(intersect)
	
	var candidates = []
	var fallback = null
	for boundary in Engine.get_main_loop().get_nodes_in_group("card_boundary").filter(func(b):
			return b.is_visible_in_tree() and not (ignore_parent and ignore_parent.is_ancestor_of(b))):
		if boundary.is_fallback_boundary():
			assert(fallback == null, "cannot have multiple fallback card boundaries")
			fallback = boundary
		if boundary.contains_screen_position(pos):
			candidates.push_back(boundary)
	
	if candidates.is_empty():
		assert(fallback, "did not find fallback boundary")
		return fallback
	
	var best: Node2D = candidates[0]
	for candidate in candidates:
		if best.is_ancestor_of(candidate): best = candidate
	return best

static func card_moved(card: Card, new_boundary = null):
	var boundary = new_boundary if new_boundary else boundary_at_card(card)
	var old_boundary = get_card_boundary(card)
	if old_boundary != boundary:
		var old_index = card.get_index()
		var old_position = card.global_position
		card.reparent(boundary)
		card.global_position = old_position if new_boundary else boundary.get_global_mouse_position()
		old_boundary.card_left(card)
		boundary.card_entered(card)
		
		if old_boundary.duplicate_on_drag:
			var dupl = card.clone()
			old_boundary.add_child(dupl)
			old_boundary.move_child(dupl, old_index)
			
			# FIXME Card.editor_sync("cards:spawn", [boundary.get_path(), card.id, card.get_script().resource_path, card.get_index()])
		old_boundary._relayout()

func add_card(card: Card): add_child(card)

func is_fallback_boundary():
	for id in get_shape_owners():
		if not is_shape_owner_disabled(id):
			return false
	return true

func contains_screen_position(pos: Vector2):
	for id in get_shape_owners():
		if is_shape_owner_disabled(id): continue
		for sid in range(0, shape_owner_get_shape_count(id)):
			var shape = shape_owner_get_shape(id, sid)
			var rect = shape_owner_get_transform(id) * shape.get_rect()
			rect = get_viewport_transform() * get_global_transform() * rect
			if rect.has_point(pos):
				return true
	return false

func get_parent_card(): return G.closest_parent_that(self, func(n): return n is Card)

func card_left(card: Card):
	card.parent = null

func card_entered(card: Card):
	card.disable = disable_on_enter
	card.paused = pause_on_enter
	card.parent = get_parent_card()
	card.init_signatures()
	if card.visual:
		var tween = card.visual.create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC) \
			.tween_property(card, "scale", Vector2(card_scale, card_scale), 0.25)

func card_picked_up(card: Card):
	card.create_tween().tween_property(card, "rotation", 0, 0.1).set_trans(Tween.TRANS_EXPO)
	card.create_tween().tween_property(card, "scale", Vector2(card_scale * 1.1, card_scale * 1.1), 0.15).set_trans(Tween.TRANS_EXPO)

func card_dropped(card: Card):
	_relayout()
	create_tween().tween_property(card, "scale", Vector2(card_scale, card_scale), 0.15).set_trans(Tween.TRANS_EXPO)

func background_rect() -> Rect2:
	# FIXME how to make sure we pick the background and not the extra collision?
	for id in get_shape_owners():
		if shape_owner_get_shape_count(id) <= 0: continue
		var shape = shape_owner_get_shape(id, 0)
		return shape_owner_get_transform(id) * shape.get_rect()
	return Rect2()

func fill_rect(rect: Rect2):
	var id = get_shape_owners()[0]
	shape_owner_get_owner(id).position = rect.size / 2
	shape_owner_get_shape(id, 0).size = rect.size

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hovered = contains_screen_position(get_viewport().get_mouse_position())

func my_card_extent():
	return CardVisual.base_card_size * card_scale

func _relayout():
	match card_layout:
		Layout.ROW: _relayout_row()
		Layout.COLLAPSED_ROW: _relayout_collapsed_row()
		Layout.FAN: _relayout_fan()

func get_cards():
	return get_children().filter(func(s): return s is Card and not s.dragging)

func _apply_card_transform(card: Node2D, new_transform: Transform2D):
	if card.transform != new_transform:
		var tween = get_tree().create_tween()
		tween \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_QUINT) \
			.tween_property(card, "transform", new_transform, 0.15)

func _relayout_row(spacing = 30, stacked = false, extra_zoom = 1):
	var horizontal_spacing = spacing
	var background = background_rect()
	var extent = CardVisual.base_card_size * extra_zoom
	var left = background.position.x / extra_zoom / card_scale
	for card in get_cards():
		var new_transform = Transform2D(0, Vector2(left + extent.x / extra_zoom / 2, background.position.y + background.size.y / 2))
		_apply_card_transform(card, new_transform.scaled(Vector2(extra_zoom, extra_zoom) * card_scale))
		left += (extent.x / extra_zoom if not stacked else 0) + horizontal_spacing

func _relayout_collapsed_row():
	if not hovered:
		_relayout_row(30, true)
	else:
		const EXTRA_ZOOM = 2.5
		const GAP = 10
		_relayout_row(GAP, false, EXTRA_ZOOM)
		
		var extent = my_card_extent() * EXTRA_ZOOM
		_extra_collision.shape = RectangleShape2D.new()
		_extra_collision.shape.size = Vector2((extent.x + GAP) * get_cards().size(), extent.y)
		_extra_collision.position = Vector2(_extra_collision.shape.size.x / 2 - extent.x / 2, 0)

func _relayout_fan():
	if not hovered:
		_relayout_row(30, true)
	else:
		const EXTRA_ZOOM = 1.8
		
		var extent = my_card_extent() * EXTRA_ZOOM
		_extra_collision.shape = RectangleShape2D.new()
		_extra_collision.shape.size = Vector2(Vector2(extent.y * 2 + 200, 200 + extent.y))
		_extra_collision.position = Vector2(0, -extent.y / 2)
		
		# make sure the full rect is on screen
		var rect = _extra_collision.get_viewport_transform() * _extra_collision.get_global_transform() * _extra_collision.shape.get_rect()
		# FIXME also check for bottom / right
		var delta = Vector2.ZERO # Vector2.ZERO.max(-rect.position)
		_extra_collision.position += delta
		
		var c = get_cards()
		var i = c.size() / -2
		if c.size() % 2 == 0: i += 0.5
		for card in c:
			var new_transform = Transform2D(i * PI / c.size(), Vector2.ZERO) * Transform2D(0, Vector2(0, -120))
			new_transform = Transform2D(0, delta) * new_transform.scaled(Vector2(EXTRA_ZOOM, EXTRA_ZOOM))
			_apply_card_transform(card, new_transform)
			i += 1
