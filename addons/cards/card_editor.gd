extends Panel

var card

func attach_cards(card: Card):
	self.card = card
	%Column.add_child(card.cards_parent)
	
	layout_cards(card.cards_parent.get_children().filter(func (c): return c is Card))
	card.cards_parent.fill_rect(get_rect())

func detach_cards():
	%Column.remove_child(card.cards_parent)

func _on_save_button_pressed() -> void:
	print(card.serialize_gdscript())

func init_positions(cards: Array):
	const RADIUS = 200.0 # Radius of the circular layout
	const CENTER = Vector2(800, 600) # Center of the initial layout (arbitrary)
	var angle_step = 2.0 * PI / cards.size()
	
	var inputs = cards.filter(func(c): return c.get_all_incoming().is_empty())
	for i in range(inputs.size()):
		inputs[i].position = Vector2(0, 400 + i * 400)
	
	var other = cards.filter(func(c): return not (inputs.has(c)))
	for i in range(other.size()):
		var angle = i * angle_step
		other[i].position = CENTER + Vector2(RADIUS * cos(angle), RADIUS * sin(angle))

func layout_cards(cards):
	const MAX_DISTANCE = 200.0
	const REPULSION_FORCE = 300000.0
	const ATTRACTION_FORCE = 1.0
	const ITERATIONS = 5000
	
	init_positions(cards)
	
	for _i in range(ITERATIONS):
		var forces = {}
		for card in cards: forces[card] = Vector2(0, 0)
		
		# repulsion
		for i in range(cards.size()):
			for j in range(i + 1, cards.size()):
				var card_a = cards[i]
				var card_b = cards[j]
				var delta = card_a.position - card_b.position
				var dist = delta.length()
				if dist > 0:
					var repulsion = dist * dist
					repulsion = REPULSION_FORCE / repulsion
					repulsion *= delta.normalized()
					forces[card_a] += repulsion
					forces[card_b] -= repulsion
		
		# attraction
		for card in cards:
			for target in card.get_all_outgoing():
				var delta = target.position - card.position
				var dist = delta.length()
				if dist > 0:
					# pull strongly to inputs
					var factor = 3 if card.get_all_incoming().is_empty() else 1
					var attraction = ATTRACTION_FORCE * factor * delta.normalized()
					# prefer straight lines
					attraction.y *= 2
					forces[card] += attraction
					forces[target] -= attraction
		
		if _i % 1000 == 0: await get_tree().process_frame
		
		for card in cards:
			if not card.get_all_incoming().is_empty(): card.position += forces[card] * 5
