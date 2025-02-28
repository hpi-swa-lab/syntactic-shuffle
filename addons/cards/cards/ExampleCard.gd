@tool
extends Card
class_name ExampleCard

func v():
	title("Example")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAD5JREFUOI1j/P//PwMlgAWZw8jIiNe0////M6KLMVFkPboL8NmEC1DsgoE3AGsY4IqN0VigkQEDHwuMlGZnAHatGB/mtXQHAAAAAElFTkSuQmCC")
	container_size(Vector2(1671.442, 1758.919))

func s():
	var cell_card = CellCard.create("value", "Variant", null)
	cell_card.position = Vector2(755.3956, 81.63489)
	
	var code_card = CodeCard.create([["edit", trg()], ["object", any("T")]], [["out", any("T")]], func (card, out, object):
		out.call(object)
, ["object"])
	code_card.position = Vector2(1200.31, 547.8441)
	
	var code_card_2 = CodeCard.create([["editor", cmd("leave", t("CardEditor"))]], [["out", t("Object")]], func (card, out, enter_card_editor):
		out.call(null)
, [])
	code_card_2.position = Vector2(607.2126, 1047.64)
	
	var enter_leave_card_card = EnterLeaveCardCard.new()
	enter_leave_card_card.position = Vector2(570.7454, 1664.202)
	
	var filter_signatures_card = FilterSignaturesCard.new(cmd("enter", any("T")))
	filter_signatures_card.position = Vector2(1084.863, 1529.205)
	
	var filter_signatures_card_2 = FilterSignaturesCard.new(cmd("leave", any("T")))
	filter_signatures_card_2.position = Vector2(233.1626, 1169.627)
	
	var forward_trigger_card = ForwardTriggerCard.new()
	forward_trigger_card.position = Vector2(1367.304, 965.8754)
	
	var in_card = InCard.data(any("T"))
	in_card.position = Vector2(100.0, 400.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1349.998, 109.4331)
	
	var signal_card = SignalCard.new()
	signal_card.position = Vector2(1002.681, 1078.451)
	signal_card.get_cell("signal_name").data = "after_edit"
	signal_card.get_cell("callback").data = null
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(390.1943, 120.2982)
	
	cell_card.c(out_card)
	cell_card.c_named("object", code_card)
	code_card.c(out_card)
	code_card_2.c(signal_card)
	enter_leave_card_card.c(filter_signatures_card)
	enter_leave_card_card.c(filter_signatures_card_2)
	filter_signatures_card.c(signal_card)
	filter_signatures_card_2.c_named("editor", code_card_2)
	forward_trigger_card.c_named("edit", code_card)
	in_card.c(store_card)
	signal_card.c(forward_trigger_card)
	store_card.c(cell_card)
