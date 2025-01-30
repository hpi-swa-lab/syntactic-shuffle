@tool
extends Node2D
class_name CardVisual

enum Type {
	Trigger,
	Effect,
	Store
}

static var base_card_size = Vector2(10, 10)

signal dragging(d: bool)

var expanded = false:
	get: return expanded
	set(v):
		expanded = v
		%Description.visible = not expanded
		%Icon.reparent(%IconMargin if not expanded else %HeaderRow)
		%Icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL if expanded else TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		if expanded: %MainColumn.add_child(card.cards_parent)
		else: %MainColumn.remove_child(card.cards_parent)
		
		$CardControl.size = Vector2(197, 282) if not expanded else Vector2(800, 600) * 3
		z_index = 100 if expanded else 0
		
		if expanded:
			layout_cards(card.cards)
			card.cards_parent.fill_rect($CardControl.get_rect())

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

@export var paused = false:
	get: return paused
	set(v):
		paused = v
		$CardControl.self_modulate = Color(Color.WHITE, 0.5 if paused else 1.0)

func title(s: String): %Name.text = s
func description(s: String): %Description.text = s
func icon(s: Texture): %Icon.texture = s
func ui(c: Control): %extra_ui.add_child(c)

var card: Card:
	get: return get_parent()

func _ready() -> void:
	$CardControl.gui_input.connect(input_event)
	base_card_size = $CardControl.size

var held = false
func input_event(e: InputEvent):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		held = e.is_pressed()
		dragging.emit(held)
	if e is InputEventMouseMotion and held:
		get_parent().position += e.screen_relative / get_viewport_transform().get_scale() / card.get_card_boundary().global_scale
	if e is InputEventMouseButton and e.double_click:
		held = false
		dragging.emit(held)
		expanded = not expanded

# if we move from the hand to the main scene, we won't receive the mouse button up
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion and held:
		input_event(e)
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and held and not e.is_pressed():
		input_event(e)
