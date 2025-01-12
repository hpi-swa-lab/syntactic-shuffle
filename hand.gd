@tool

extends Node2D

@export var horizontal_spacing = 15

func add_card(card):
	card.reparent($Cards)
	card.disable = true
	card.global_position = get_viewport().get_mouse_position() # ;)
	_relayout()

func remove_card(card):
	if card.get_parent() != $Cards:
		push_error("Tried to remove card that is not in hand. ", card)
		return
	card.disable = false
	card.reparent(get_tree().current_scene)
	card.global_position = get_viewport().get_camera_2d().get_global_mouse_position()
	_relayout()

func background_size() -> Vector2:
	return $Background.size

func _relayout():
	var left = horizontal_spacing
	for card in $Cards.get_children():
		var extent = card.get_extent()
		var new_position = Vector2(left + extent.x / 2, background_size().y / 2)
		var tween = get_tree().create_tween()
		tween\
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.tween_property(card, "position", new_position, 0.25)
		left += extent.x + horizontal_spacing

func includes_screen_point(point):
	var s = %shape.shape.get_rect()
	s.position += %shape.global_position
	return s.has_point(point)
