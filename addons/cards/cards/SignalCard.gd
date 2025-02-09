@tool
extends Card
class_name SignalCard

func v():
	title("Signal")
	description("Connect to a singal and trigger when it emits.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGFJREFUOI3FUjESACAIsv7/51oaUsG4GnLxLgiUMnustvog59cCshAiIDEqVDlIa8UVThMlXA2RilTEiEMRlgFzTKv2DThdggYdAFWgNETkxl7IceIEyhd2HJSB4pwE/tUEsg8ZEXMVq5oAAAAASUVORK5CYII=")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(1836.92, 819.9062)
	var code_card = CodeCard.create([["obj", cmd("connect", t("Object"))], ["signal_name", t("String")]], [["out", trg()], ["callable", t("Callable")]], func (card, out, callable, obj, signal_name):
		var sig = null
		for s in obj.get_signal_list():
			if s["name"] == signal_name:
				sig = s
				break
		if not sig: return
		var args = sig["args"]
		var out_sig = Signature.TriggerSignature.new() if args.is_empty() else Signature.signature_for_type(args[0]["type"])
		var sub
		if args.is_empty(): sub = func (): out.call(null)
		else: sub = func (arg): out.call(arg)
		for o in card.parent.get_outputs():
			o.signature = out_sig
		card.get_outputs()[0].signature = out_sig
		card.parent.start_propagate_incoming_connected()
		callable.call(sub)
		obj.connect(signal_name, sub)
, ["signal_name"])
	code_card.position = Vector2(1282.875, 863.4362)
	var code_card_2 = CodeCard.create([["obj", cmd("disconnect", t("Object"))], ["callable", t("Callable")], ["signal_name", t("String")]], [["out", t("Callable")]], func (card, out, obj, callable, signal_name):
		if callable: obj.disconnect(signal_name, callable)
		out.call(null)
, ["callable", "signal_name"])
	code_card_2.position = Vector2(522.8999, 628.7775)
	var subscribe_in_card = SubscribeInCard.new(t("Object"))
	subscribe_in_card.position = Vector2(906.773, 792.4158)
	var cell_card = CellCard.create("signal_name", "String", "")
	cell_card.position = Vector2(972.0753, 293.4023)
	var cell_card_2 = CellCard.create("callback", "Callable", null)
	cell_card_2.position = Vector2(591.1655, 1287.221)
	var store_card = StoreCard.new()
	store_card.position = Vector2(1192.607, 1315.579)
	var store_card_2 = StoreCard.new()
	store_card_2.position = Vector2(181.4052, 1039.797)
	
	code_card.c(out_card)
	code_card.c(store_card)
	code_card_2.c(store_card_2)
	subscribe_in_card.c_named("obj", code_card)
	subscribe_in_card.c_named("obj", code_card_2)
	cell_card.c_named("signal_name", code_card_2)
	cell_card.c_named("signal_name", code_card)
	cell_card_2.c_named("callable", code_card_2)
	store_card.c(cell_card_2)
	store_card_2.c(cell_card_2)
