@tool
extends OutCard
class_name StaticOutCard

func _init(name: String, signature: Signature, remember = false) -> void:
	assert(signature != null)
	self.output_name = name
	self.static_signature = signature
	super._init(remember)

var output_name: String
var static_signature: Signature
var overridden_signatures: Array[Signature]

func _get_aggregate():
	return parent is CodeCard and parent.inputs.any(func(pair): return pair[1] is Signature.IteratorSignature)

func _get_base_signatures():
	# InCard's have a special OutCard -- this is us
	#if parent is InCard: return parent.actual_signatures
	return overridden_signatures if overridden_signatures else [static_signature]

func override_signature(signatures: Array[Signature], apply_direct = false):
	if overridden_signatures and Signature.signatures_equal(overridden_signatures, signatures): return
	overridden_signatures = signatures
	# for example in CellCards, we do not necessarily update the signature during a propagation call, as it may not be have inputs
	if apply_direct:
		update_my_signatures()
	
	card_parent_in_world().start_propagate_incoming_connected()

func v():
	title("Static Output")
	description("Emit output and advertise a static signature.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIZJREFUOI3FUjsOwCAIBdOlEwfx/kfxIEzdtJMEVNB06ZsMvA8RAP5EIQJ0es2pC78Q2cIgjoyxi1cGkbgnG44mS0MnOFOI9lokaNLOCNMBMTSZJui4a5X3k/wc1yASKaBnEG3CfKKOQQBomRky86Qaass16gT3kAqR6X065egSj7E5tnOTFy92Ir2sNy07AAAAAElFTkSuQmCC")

func serialize_constructor():
	return "{0}.new({1}, {2}, {3})".format([
		card_name,
		Signature.data_to_expression(output_name),
		static_signature.serialize_gdscript(),
		remember_message])
