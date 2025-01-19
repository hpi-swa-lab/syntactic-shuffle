@tool
extends Card
class_name CodeCard

static func create(inputs: Dictionary[String, String], signature: Array[String], process: Callable):
	var c = CodeCard.new()
	c.signature = signature
	c.process = process
	c.inputs = inputs
	return c

var signature: Array[String]
var process: Callable
var inputs: Dictionary[String, String]

func s():
	title("Code")
	description("Run some code.")
	icon("code.png")
	
	var out_card = OutCard.static_signature(signature)
	
	for input in inputs:
		NamedInCard.named_data(input, inputs[input])

func invoke(args: Array, signature: Array[String], named = "", remember = false):
	assert(named, "code cards can only receive named input")
	if process.get_argument_count() == 1:
		process.call(self)
	else:
		var combined_args = {named: args}
		for card in cards:
			if card is NamedInCard and card.input_name != named:
				var remembered = card.get_remembered()
				# not enough args yet
				if not remembered: return
				combined_args[card.input_name] = remembered
		process.call(self, combined_args)

func output(args: Array):
	invoke_outputs(args, signature)
