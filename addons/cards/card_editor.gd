extends Panel

var card

func attach_cards(card: Card):
	self.card = card
	%Column.add_child(card.cards_parent)
	
	%Name.text = card.visual.get_title()
	%Icon.texture_normal = card.visual.get_icon_texture()
	
	if card.cards_parent.get_children().filter(func (c):
		return c is Card and c.position != Vector2.ZERO).is_empty():
		_on_auto_layout_pressed()

func detach_cards():
	%Column.remove_child(card.cards_parent)

func _on_save_button_pressed() -> void:
	var path
	var src
	if card is BlankCard:
		assert(%Name.text)
		var n = %Name.text + "Card"
		path = "res://addons/cards/{0}.gd".format([n])
		src = card.serialize_gdscript(n)
	else:
		# TODO handle name change
		path = card.get_script().resource_path
		src = card.serialize_gdscript()
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(src)

func _on_auto_layout_pressed() -> void:
	layout_cards(card.cards_parent.get_children().filter(func (c): return c is Card))

func init_positions(cards: Array):
	const RADIUS = 200.0
	const CENTER = Vector2(800, 600)
	var angle_step = 2.0 * PI / cards.size()
	
	var inputs = cards.filter(func(c): return c.get_all_incoming().is_empty())
	for i in range(inputs.size()):
		inputs[i].position = Vector2(200, 400 + i * 400)
	
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


func _on_icon_pressed() -> void:
	var editor = preload("res://addons/cards/icon_editor.tscn").instantiate()
	get_parent().add_child(editor)
	editor.global_position = %Icon.global_position - editor.get_rect().size / 2
	
	editor.texture = ImageTexture.create_from_image(%Icon.texture_normal.get_image())
	
	editor.save.connect(func(texture):
		%Icon.texture_normal = texture
		card.visual.set_icon_texture(texture))
