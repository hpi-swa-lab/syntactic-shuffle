@tool
extends Card
class_name CodeCard

static func create(inputs: Array[Array], outputs: Dictionary[String, Signature], process: Callable, pull_only = []):
	var c = CodeCard.new()
	c.outputs = outputs
	c.process = process
	c.inputs = inputs
	c.pull_only = pull_only
	return c

var outputs: Dictionary[String, Signature]
var process: Callable
var inputs: Array[Array]
var pull_only: Array

func s():
	title("Code")
	description("Run some code.")
	icon(preload("res://addons/cards/icons/code.png"))
	
	for output in outputs:
		OutCard.static_signature(outputs[output])
	
	for pair in inputs:
		NamedInCard.named_data(pair[0], pair[1])

func invoke(args: Array, signature: Signature, named = "", source_out = null):
	if not inputs.is_empty(): assert(named, "code cards with inputs can only have named connections")
	if pull_only.has(named): return
	
	var combined_args = [self]
	var pulled_remembered = []
	for pair in inputs:
		if pair[0] == named:
			if not signature.compatible_with(pair[1]): return
			if not pair[1].provides_data(): continue
			combined_args.append_array(args)
		else:
			if not pair[1].provides_data(): continue
			var card
			for c in cards: if c is NamedInCard and c.input_name == pair[0]: card = c
			if not card: return
			var remembered = card.get_remembered()
			# not enough args yet
			if remembered == null: return
			combined_args.append_array(remembered.get_remembered_value())
			pulled_remembered.push_back(remembered)
	# FIXME very noisy -- add extra protocol?
	# for out in pulled_remembered: out.mark_activated(parent)
	assert(process.get_argument_count() == combined_args.size())
	process.callv(combined_args)

func output(name: String, args: Array):
	var signature = outputs[name]
	for card in get_outgoing():
		card.invoke(args, signature)
