@tool
extends Card
class_name AlwaysCard

func v():
	title("Always")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGZJREFUOI3Fk0EKACEMA3dk///l7EmooUpFYXOz2DGGFknPidpR9w3AmxWB4V+SKAMAeUNW62qVi73mzgbA6pXY7JBSiBEuiQgpAdxZPN+bA7fmmmU0OJhBVgGT7cLOIKWAHf2/TB/mI0UZsePXKAAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var enter_leave_card_card = EnterLeaveCardCard.new()
	enter_leave_card_card.position = Vector2(397.3763, 844.6288)
	var signal_card = SignalCard.new()
	signal_card.position = Vector2(915.5621, 1050.628)
	signal_card.cards[4].data = "process"
	signal_card.cards[5].data = null
	var out_card = OutCard.new()
	out_card.position = Vector2(1404.338, 1168.536)
	
	enter_leave_card_card.c(signal_card)
	signal_card.c(out_card)
