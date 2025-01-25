@tool
extends InCard
class_name NamedInCard

static func named_data(name: String, signature: Signature):
	var c = NamedInCard.new()
	c.signature = signature
	c.input_name = name
	return c

@export var input_name: String

func v():
	title("Named Input")
	description("Receive input via a named connection.")
	icon(preload("res://addons/cards/icons/forward.png"))
	
	var e = LineEdit.new()
	e.placeholder_text = "Input Name"
	if input_name != null: e.text = input_name
	e.text_changed.connect(func (): input_name = e.text)
	ui(e)

func try_connect(them: Node):
	if not parent or parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	var named = parent.named_incoming
	var p = parent.get_path_to(them)
	for name in named:
		# don't allow them to appear in multiple connections to us
		if named[name].has(p): return
		# only allow one connection to us
		if name == input_name and not named[name].is_empty(): return
	
	for card in get_object_cards(them):
		if card is OutCard:
			var their_signatures = [] as Array[Signature]
			card.get_out_signatures(their_signatures)
			for their_signature in their_signatures:
				if signature.compatible_with(their_signature):
					connect_to(them, parent, input_name)
					return

func _get_remembered_for(signature: Signature):
	for p in parent.named_incoming[input_name]:
		var card = parent.get_node_or_null(p)
		if card and is_valid_incoming(card, signature):
			var val = get_remembered_for(card, signature)
			if val != null: return val
	return null
