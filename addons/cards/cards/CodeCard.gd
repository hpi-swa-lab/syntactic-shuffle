@tool
extends Card
class_name CodeCard

static func create(inputs: Dictionary[String, String], signature: Array[String], process: Callable, pull_only = []):
	var c = CodeCard.new()
	c.signature = signature
	c.process = process
	c.inputs = inputs
	c.pull_only = pull_only
	return c

var signature: Array[String]
var process: Callable
var inputs: Dictionary[String, String]
var pull_only: Array

func s():
	title("Code")
	description("Run some code.")
	icon("code.png")
	
	var out_card = OutCard.static_signature(signature)
	
	for input in inputs:
		NamedInCard.named_data(input, inputs[input])

func invoke(args: Array, signature: Array[String], named = ""):
	if not inputs.is_empty():
		assert(named, "code cards with inputs can only have named connections")
	if process.get_argument_count() == 1:
		process.call(self)
	else:
		if pull_only.has(named): return
		var combined_args = {named: args}
		for input_name in inputs:
			if input_name != named:
				var card
				for c in cards: if c is NamedInCard and c.input_name == input_name: card = c
				if not card: return
				var remembered = card.get_remembered()
				# not enough args yet
				if remembered == null: return
				combined_args[card.input_name] = remembered
		process.call(self, combined_args)

func output(args: Array):
	invoke_outputs(args, signature)
