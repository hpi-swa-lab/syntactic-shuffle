@tool
extends Card
class_name AlwaysCard

func v():
	title("Always")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGZJREFUOI3Fk0EKACEMA3dk///l7EmooUpFYXOz2DGGFknPidpR9w3AmxWB4V+SKAMAeUNW62qVi73mzgbA6pXY7JBSiBEuiQgpAdxZPN+bA7fmmmU0OJhBVgGT7cLOIKWAHf2/TB/mI0UZsePXKAAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var signal_card = SignalCard.new()
	signal_card.position = Vector2(907.3478, 400.15)
	signal_card.cards[4].data = "process"
	signal_card.cards[5].data = null
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1771.475, 389.3198)
	
	var enter_leave_card_card = EnterLeaveCardCard.new()
	enter_leave_card_card.position = Vector2(175.5747, 1217.136)
	
	var unwrap_command_card = UnwrapCommandCard.new()
	unwrap_command_card.position = Vector2(536.9548, 400.3845)
	
	var filter_signatures_card = FilterSignaturesCard.new(t("float"))
	filter_signatures_card.position = Vector2(1321.958, 409.9802)
	
	var filter_signatures_card_2 = FilterSignaturesCard.new(cmd("enter", any("T")))
	filter_signatures_card_2.position = Vector2(179.5218, 615.3729)
	
	var forward_trigger_card = ForwardTriggerCard.new()
	forward_trigger_card.position = Vector2(985.881, 1089.25)
	
	var out_card_2 = OutCard.new(false)
	out_card_2.position = Vector2(1501.513, 1099.381)
	
	signal_card.c(filter_signatures_card)
	signal_card.c(forward_trigger_card)
	enter_leave_card_card.c(filter_signatures_card_2)
	unwrap_command_card.c(signal_card)
	filter_signatures_card.c(out_card)
	filter_signatures_card_2.c(unwrap_command_card)
	forward_trigger_card.c(out_card_2)
