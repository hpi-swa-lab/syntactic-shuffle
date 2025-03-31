@tool
extends Card
class_name BreakpointCard

func v():
	title("Breakpoint")
	description("Pause execution for debugging when reached.")
	icon(preload("res://addons/cards/icons/bool.png"))

func s():
	# FIXME not sure yet how to do this best
	# would need a code card that allows us to place the breakpoint but also
	# does not modify out/in puts
	pass
