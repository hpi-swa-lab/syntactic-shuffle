extends Camera2D
class_name CardCamera

@export var zoom_speed = 0.1
@export var pan = true

var held = false
var selecting = false
var selection = {}

func clear_selection():
	for card in selection:
		if is_instance_valid(card) and card.visual: card.visual.on_deselected()
	selection.clear()

func set_as_selection(obj: Node):
	clear_selection()
	add_to_selection(obj)

func is_selected(obj: Node):
	return selection.has(obj)

func add_to_selection(obj: Node):
	selection[obj] = true
	if obj.visual: obj.visual.on_selected()

func consider_selection(obj: Node):
	if selecting: add_to_selection(obj)

func move_selected(delta: Vector2):
	for card in selection: card.position += delta

func delete_selected():
	for card in selection:
		if is_instance_valid(card): card.queue_free()
	selection.clear()

func duplicate_selected():
	var src = Card.serialize_card_construction(selection.keys())
	
	var container = G.eval_object("@tool\nextends Card\nfunc s():\n{0}".format([src]), func(): return Card.new())
	
	var parent = selection.keys()[0].get_parent()
	clear_selection()
	for c in container.cards:
		container.cards_parent.remove_child(c)
		parent.add_child(c)
		add_to_selection(c)

func group_selected():
	var cards = selection.keys()
	clear_selection()
	
	var parent = BlankCard.new()
	cards[0].get_parent().add_child(parent)
	parent.position = cards.map(func(c): return c.position).reduce(func (sum, v): return sum + v) / cards.size() - CardVisual.DEFAULT_EDITOR_SIZE * parent.get_base_scale() * 0.25
	if parent.visual: parent.visual.expanded = true
	
	var then = []
	var incoming = []
	var outgoing = []
	var add_input = func(from, to, named):
		var sig = [] as Array[Signature]
		Card.get_object_out_signatures(from, sig)
		# FIXME choosing first
		var input = NamedInCard.named_data(named, sig[0]) if named else InCard.data(sig[0])
		input.parent = parent.cards_parent
		parent.cards_parent.add_child(input)
		then.push_back(func ():
			Card.connect_to(from, parent, named)
			Card.object_disconnect_from(to, from)
			Card.connect_to(input, to, named))
	var add_output = func(from, to, named):
		var output = OutCard.new()
		output.parent = parent.cards_parent
		parent.cards_parent.add_child(output)
		then.push_back(func ():
			Card.connect_to(parent, to, named)
			Card.object_disconnect_from(from, to)
			from.c(output))
	
	for c in cards:
		for i in c.get_incoming(): if not cards.has(i): incoming.push_back([i, c, ""])
		for i in c.get_outgoing(): if not cards.has(i): outgoing.push_back([c, i, ""])
		for n in c.named_incoming:
			for p in c.named_incoming[n]:
				var i = c.get_node(p)
				if not cards.has(i): incoming.push_back([i, c, n])
		for n in c.named_outgoing:
			for p in c.named_outgoing[n]:
				var i = c.get_node(p)
				if not cards.has(i): outgoing.push_back([c, i, n])
	for c in cards: CardBoundary.card_moved(c, parent.cards_parent)
	
	for pair in incoming: add_input.call(pair[0], pair[1], pair[2])
	for pair in outgoing: add_output.call(pair[0], pair[1], pair[2])
	for t in then: t.call()
	var i_y = 0
	var o_y = 0
	for i in parent.cards:
		if i is InCard:
			i.position = Vector2(100, 400 * i_y + 400)
			i_y += 1
		if i is OutCard:
			i.position = Vector2(CardVisual.DEFAULT_EDITOR_SIZE.x - 100, 400 * o_y + 400)
			o_y += 1
	
	return parent

func _ready(): Card.set_ignore_object(self)

func _zoom(factor: float) -> void:
	var delta = get_global_mouse_position() - global_position
	delta = delta - delta * zoom.x / (zoom.x + factor)
	zoom += Vector2(factor, factor)
	position += delta

func _input(event: InputEvent) -> void:
	if event is InputEventPanGesture:
		_zoom(-1 * event.delta.y * zoom.x)
	if event is InputEventMouseButton:
		var factor = 0
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: factor = -1
			MOUSE_BUTTON_WHEEL_UP: factor = 1
			_: factor = 0
		
		if factor != 0:
			factor *= event.factor * zoom_speed * zoom.x
			_zoom(factor)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and pan:
		held = event.is_pressed()
	if event is InputEventMouseMotion and held:
		position -= event.screen_relative / zoom

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selecting = event.is_pressed()
		if selecting: clear_selection()
	if event is InputEventKey and event.key_label == KEY_DELETE and event.pressed:
		delete_selected()
	if event is InputEventKey and event.key_label == KEY_D and event.ctrl_pressed and event.pressed:
		duplicate_selected()
	if event is InputEventKey and event.key_label == KEY_G and event.ctrl_pressed and event.pressed:
		group_selected()
