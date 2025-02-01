@tool
extends Card
class_name FilterSignaturesCard

var in_card: InCard
var out_card: OutCard

var signature: Signature = Signature.VoidSignature.new():
	get: return signature
	set(v):
		signature = v
		if out_card: out_card.signature = v
		if in_card: in_card.signature = v

func _init(signature):
	self.signature = signature
	super._init()

func v():
	title("FilterSignatures")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF1JREFUOI3dkjEOwDAIA7mo//+yu1WoCZSErYyIMwYZSdap0aLN7Ho3gMeSJLYdVKBUANCOCP6JEezPCgU8vONirABJZFsnB9nwlxOiIFXPmHKwgktPPK12lH8gcAMpdz8P8w5/ngAAAABJRU5ErkJggg==")
	signature_edit()

func can_edit(): return false

func s():
	in_card = InCard.data(none())
	in_card.position = Vector2(260.0294, 667.1127)
	out_card = OutCard.new()
	out_card.position = Vector2(1253.268, 679.9912)
	
	in_card.c(out_card)
	
	signature = signature

func signature_edit():
	var edit = preload("res://addons/cards/signature/signature_edit.tscn").instantiate()
	edit.on_edit.connect(func (s): signature = s)
	edit.signature = signature
	ui(edit)

func serialize_constructor():
	return "{0}.new({1})".format([get_card_name(), signature.serialize_gdscript()])

func clone():
	return get_script().new(signature)
