@tool
extends InCard
class_name NamedInCard

@export var input_name: String

static func named_data(name: String, signature: Signature):
	return NamedInCard.new(name, signature)

func _init(name: String, signature: Signature):
	self.input_name = name
	super._init(signature)

func v():
	title("Named Input")
	description("Receive input via a named connection.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAALVJREFUOI3FkiEWAyEMRD/INblCV1f0/sdAoOkVMGtTAxSysO2r6RjeSzKZMAn8E1EEt8jpIt7qo8gYMOSrxq6SAfyKnOZTODtdr9TIUYQtZ+1rjqK65cwOGkVc6xhK5QMI5a1IZyF20FRiHkMwxH66KTwT1aLyFZqJwSTMBKutnE2Mb7MU4Kbqnm7kVw+OySHZNQ75Q4R7zm0Dq9EGYv1K8WQgX/3t8pT7S1ya8wl9k58RRXgB3fI5LJ/pk0UAAAAASUVORK5CYII=")
	signature_edit()
	
	var e = LineEdit.new()
	e.placeholder_text = "Input Name"
	if input_name != null: e.text = input_name
	e.text_changed.connect(func (): input_name = e.text)
	ui(e)

func try_connect_in(them: Node):
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
	for p in parent.named_incoming.get(input_name, []):
		var card = parent.get_node_or_null(p)
		if card and is_valid_incoming(card, signature):
			var val = get_remembered_for(card, signature)
			if val != null: return val
	return null

func serialize_constructor():
	return "{0}.new(\"{1}\", {2})".format([get_card_name(), input_name, signature.serialize_gdscript()])
