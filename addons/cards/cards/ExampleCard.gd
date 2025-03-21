@tool
extends Card
class_name ExampleCard

func v():
	title("Example")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAD5JREFUOI1j/P//PwMlgAWZw8jIiNe0////M6KLMVFkPboL8NmEC1DsgoE3AGsY4IqN0VigkQEDHwuMlGZnAHatGB/mtXQHAAAAAElFTkSuQmCC")
	container_size(Vector2(2150.427, 1427.369))

func s():
	var cell_card = CellCard.create("value", "Variant", null)
	cell_card.position = Vector2(1394.642, 190.0054)
	
	var code_card = CodeCard.create([["editor", cmd("leave", t("CardEditor"))]], [["out", t("Object")]], func (card, out, enter_card_editor):
		out.call(null)
, [])
	code_card.position = Vector2(755.4949, 726.3682)
	
	var code_card_2 = CodeCard.create([["edit", trg()], ["object", any("T")]], [["out", any("T")]], func (card, out, object):
		out.call(object)
, ["object"])
	code_card_2.position = Vector2(1816.71, 723.4033)
	
	var enter_leave_card_card = EnterLeaveCardCard.new()
	enter_leave_card_card.position = Vector2(184.2047, 1148.874)
	
	var filter_signatures_card = FilterSignaturesCard.new(cmd("leave", any("T")))
	filter_signatures_card.position = Vector2(382.5439, 759.4637)
	
	var filter_signatures_card_2 = FilterSignaturesCard.new(cmd("enter", any("T")))
	filter_signatures_card_2.position = Vector2(767.1326, 1159.027)
	
	var forward_trigger_card = ForwardTriggerCard.new()
	forward_trigger_card.position = Vector2(1413.343, 753.3837)
	
	var in_card = InCard.data(any("T"))
	in_card.position = Vector2(602.8976, 212.2982)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1948.516, 217.4499)
	
	var signal_card = SignalCard.new()
	signal_card.position = Vector2(1085.906, 708.3606)
	signal_card.get_cell("signal_name").data = "after_edit"
	signal_card.get_cell("callback").data = null
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(1019.545, 202.8178)
	
	cell_card.c(out_card)
	cell_card.c_named("object", code_card_2)
	code_card.c(signal_card)
	code_card_2.c(out_card)
	enter_leave_card_card.c(filter_signatures_card)
	enter_leave_card_card.c(filter_signatures_card_2)
	filter_signatures_card.c_named("editor", code_card)
	filter_signatures_card_2.c(signal_card)
	forward_trigger_card.c_named("edit", code_card_2)
	in_card.c(store_card)
	signal_card.c(forward_trigger_card)
	store_card.c(cell_card)
