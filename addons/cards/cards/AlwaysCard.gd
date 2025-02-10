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
	signal_card.position = Vector2(1005.652, 393.6871)
	signal_card.cards[4].data = "process"
	signal_card.cards[5].data = null
	var out_card = OutCard.new()
	out_card.position = Vector2(1624.379, 366.8322)
	var enter_leave_card_card = EnterLeaveCardCard.new()
	enter_leave_card_card.position = Vector2(200.0, 400.0)
	var unwrap_command_card = UnwrapCommandCard.new()
	unwrap_command_card.position = Vector2(616.4738, 394.9503)
	
	signal_card.c(out_card)
	enter_leave_card_card.c(unwrap_command_card)
	unwrap_command_card.c(signal_card)
