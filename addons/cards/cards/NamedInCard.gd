@tool
extends InCard
class_name NamedInCard

@export var input_name: String

static func named_data(name: String, signature: Signature):
	return NamedInCard.new(name, signature)

func _init(name: String, signature: Signature):
	self.input_name = name
	super._init(signature)

func clone():
	return get_script().new(input_name, signature)

func v():
	title("Named Input")
	description("Receive input via a named connection.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAALVJREFUOI3FkiEWAyEMRD/INblCV1f0/sdAoOkVMGtTAxSysO2r6RjeSzKZMAn8E1EEt8jpIt7qo8gYMOSrxq6SAfyKnOZTODtdr9TIUYQtZ+1rjqK65cwOGkVc6xhK5QMI5a1IZyF20FRiHkMwxH66KTwT1aLyFZqJwSTMBKutnE2Mb7MU4Kbqnm7kVw+OySHZNQ75Q4R7zm0Dq9EGYv1K8WQgX/3t8pT7S1ya8wl9k58RRXgB3fI5LJ/pk0UAAAAASUVORK5CYII=")
	signature_edit()
	
	var e = LineEdit.new()
	e.placeholder_text = "Input Name"
	if input_name != null: e.text = input_name
	e.text_changed.connect(func(n): input_name = n)
	ui(e)

func _get_incoming_list(visited = []):
	return parent.get_named_incoming_at(input_name)

func try_connect_in(them: Node):
	if not parent or parent.get_incoming().has(them): return
	if them is Card and detect_cycles_for_new_connection(parent, them): return
	
	var named = parent.named_incoming
	var p = parent.get_path_to_card(them)
	for name in named:
		# don't allow them to appear in multiple connections to us
		if named[name].has(p): return
		# only allow one connection to us
		if name == input_name and not parent.get_named_incoming_at(name).is_empty(): return
	
	var my_signatures = actual_signatures
	for card in them.cards:
		if card is OutCard:
			for their_signature in card.output_signatures:
				for my_signature in my_signatures:
					if their_signature.compatible_with(my_signature):
						them.connect_to(parent, input_name)
						return

func should_allow_connection(from: Card, to: Card):
	return from.cycles_allowed_for(input_name)

func rename(new_name: String):
	for connected in parent.get_named_incoming_at(input_name):
		var list = connected.named_outgoing[input_name]
		connected.named_outgoing.erase(input_name)
		connected.named_outgoing[new_name] = list
	var list = parent.named_incoming[input_name]
	parent.named_incoming.erase(input_name)
	parent.named_incoming[new_name] = list
	input_name = new_name
	parent.connection_draw_node.queue_redraw()

func _get_remembered_for(signature: Signature):
	if not parent: return null
	for p in parent.named_incoming.get(input_name, []):
		var card = parent.get_node_or_null(p)
		if card and is_valid_incoming(card, signature):
			var val = card.get_remembered_for(signature)
			if val != null: return val
	return null

func serialize_constructor():
	return "{0}.named_data(\"{1}\", {2})".format([card_name, input_name, signature.serialize_gdscript()])
