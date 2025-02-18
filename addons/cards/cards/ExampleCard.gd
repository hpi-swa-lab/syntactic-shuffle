@tool
extends Card
class_name ExampleCard

func v():
	title("Example")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAD5JREFUOI1j/P//PwMlgAWZw8jIiNe0////M6KLMVFkPboL8NmEC1DsgoE3AGsY4IqN0VigkQEDHwuMlGZnAHatGB/mtXQHAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["edit", trg()], ["object", any("T")]], [["out", any("T")]], func (card, out, object):
		out.call(object)
, ["object"])
	code_card.position = Vector2(1200.31, 547.8441)
	
	var signal_card = SignalCard.new()
	signal_card.position = Vector2(600.8303, 858.0826)
	signal_card.get_cell("signal_name").data = "after_edit"
	signal_card.get_cell("callback").data = null
	
	var enter_leave_card_card = EnterLeaveCardCard.new()
	enter_leave_card_card.position = Vector2(273.4531, 1287.661)
	
	var in_card = InCard.data(any("T"))
	in_card.position = Vector2(100.0, 400.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1349.998, 109.4331)
	
	var cell_card = CellCard.create("value", "Variant", null)
	cell_card.position = Vector2(755.3956, 81.63489)
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(390.1943, 120.2982)
	
	var forward_trigger_card = ForwardTriggerCard.new()
	forward_trigger_card.position = Vector2(1022.492, 911.4312)
	
	code_card.c(out_card)
	signal_card.c(forward_trigger_card)
	enter_leave_card_card.c(signal_card)
	in_card.c(store_card)
	cell_card.c(out_card)
	cell_card.c_named("object", code_card)
	store_card.c(cell_card)
	forward_trigger_card.c_named("edit", code_card)
