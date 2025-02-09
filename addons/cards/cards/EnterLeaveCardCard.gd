@tool
extends Card
class_name EnterLeaveCardCard

func v():
	title("EnterLeaveCard")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGJJREFUOI2lkjEWwDAIQqH3vzOdsuSpSOuqIV+EktAVSUliOwDgmZpHZOxLskMA0JFYAkeyFugI6EycHq8I3BVGgk2tPQBqIyOBSqRcIclFTHB/8lngEERXqHIRE9y5+J2DF6YVOgetH11iAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func can_edit(): return false

var enter_out_card: OutCard
var leave_out_card: OutCard

func s():
	enter_out_card = OutCard.static_signature(cmd("enter"))
	enter_out_card.position = Vector2(1052.319, 453.2359)
	
	leave_out_card = OutCard.static_signature(cmd("leave"))
	leave_out_card.position = Vector2(1052.319, 653.2359)

func entered_program():
	super.entered_program()
	enter_out_card.invoke([], cmd("enter"))

func left_program():
	super.left_program()
	leave_out_card.invoke([], cmd("leave"))
