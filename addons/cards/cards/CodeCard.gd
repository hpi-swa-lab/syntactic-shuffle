@tool
extends Card
class_name CodeCard

static func create(signature: Array[String], process: Callable):
	var c = CodeCard.new()
	c.signature = signature
	c.process = process
	return c

var signature
var process

func s():
	title("Code")
	description("Run some code.")
	icon("code.png")
	
	var out_card = OutCard.data()

func invoke(args: Array, signature: Array[String], named = ""):
	if process.get_argument_count() == 1:
		process.call(self)
	else:
		process.call(self, args)

func output(args: Array):
	invoke_outputs(args, signature)
