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
	enter_out_card = StaticOutCard.new("enter", cmd("enter", t("CardEditor")), true)
	enter_out_card.position = Vector2(1052.319, 453.2359)
	
	leave_out_card = StaticOutCard.new("leave", cmd("leave", t("CardEditor")))
	leave_out_card.position = Vector2(1052.319, 653.2359)

func entered_program(editor):
	super.entered_program(editor)
	enter_out_card.invoke([editor], cmd("enter", t("CardEditor")), Invocation.new())

func left_program(editor):
	super.left_program(editor)
	leave_out_card.invoke([editor], cmd("leave", t("CardEditor")), Invocation.new())
