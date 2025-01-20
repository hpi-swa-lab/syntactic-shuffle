@tool
extends Card
class_name BreakpointCard

func s():
	title("Breakpoint")
	description("Pause execution for debugging when reached.")
	icon("bool.png")
	
	# FIXME not sure yet how to do this best
	# would need a code card that allows us to place the breakpoint but also
	# does not modify out/in puts
