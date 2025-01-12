@tool
extends Area2D
class_name CardBoundary

static func get_card_boundary(card: Card):
	var b = G.closest_parent_that(card, func (n): return n is CardBoundary)
	if not b:
		return card.get_tree().root
	return b
