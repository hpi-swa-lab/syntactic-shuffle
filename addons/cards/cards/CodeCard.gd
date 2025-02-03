@tool
extends Card
class_name CodeCard

## Returns the source code of the anonymous function at the given index in the source file.
static func fetch_source_code_in(src: String, index: int):
	if not _source_code_cache.has(src):
		_source_code_cache[src] = _extract_anonymous_functions(src)
	return _source_code_cache[src][index]
static var _source_code_cache = {}
static func _extract_anonymous_functions(src: String):
	var sources = []
	var paren_level = 1
	var current = null
	var in_comment = false
	var in_string = false
	for i in range(0, src.length()):
		var c = src[i]
		var skip = in_comment or in_string
		if current != null:
			if not skip and paren_level == 1 and (c == "," or c == ")"):
				sources.push_back(current)
				current = null
				continue
			current += c
			if not skip and c == "(": paren_level += 1
			if not skip and c == ")": paren_level -= 1
		
		if not in_string and c == "\n": in_comment = false
		if not skip and c == "#": in_comment = true
		if in_string and c == in_string and src[i - 1] != "\\": in_string = false
		if not skip and (c == "\"" or c == "'") and src[i - 1] != "\\":
			in_string = c
		
		if current == null and not skip and src.substr(i, 6) == "func (" or src.substr(i, 5) == "func(":
			current = c
	
	return sources

static func create(inputs: Array[Array], outputs: Dictionary[String, Signature], process: Callable, pull_only = []):
	var c = CodeCard.new(inputs, outputs, process, pull_only)
	return c

func _init(inputs: Array[Array], outputs: Dictionary[String, Signature], process: Callable, pull_only = [], source_code = ""):
	self.outputs = outputs
	self.process = process
	self.inputs = inputs
	self.pull_only = pull_only
	self.source_code = source_code
	super._init()
	get_source_code()

func clone():
	var c = get_script().new(inputs, outputs, process, pull_only)
	c.source_code = source_code
	return c

var outputs: Dictionary[String, Signature]
var process: Callable
var inputs: Array[Array]
var pull_only: Array

var source_code: String = "":
	get: return source_code
	set(v):
		source_code = v
		if visual: description(v.substr(0, 150))

func v():
	title("Code")
	icon(preload("res://addons/cards/icons/code.png"))
	source_code = source_code
	
	visual.short_description()

func s():
	for output in outputs:
		OutCard.static_signature(outputs[output])
	
	for pair in inputs:
		NamedInCard.new(pair[0], pair[1])

func rebuild_inputs_outputs():
	for card in cards: card.queue_free()
	cards.clear()
	build_cards_list()

func setup_finished():
	super.setup_finished()
	get_source_code()

func cycles_allowed_for(name: String): return pull_only.has(name)

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
	
	if source_out: mark_activated(source_out)
	process.callv(combined_args)

func output(name: String, args: Array):
	var signature = outputs[name]
	for card in get_outgoing():
		var output
		for o in cards:
			if o.signature == signature:
				output = o
				break
		assert(output)
		card.invoke(args, signature, "", output)

func get_source_code():
	if not source_code:
		var index = parent.cards.filter(func (c): return c is CodeCard).find(self)
		source_code = fetch_source_code_in(parent.get_script().source_code, index)
	return source_code

func serialize_constructor():
	return "CodeCard.create([{inputs}], {{outputs}}, {code}, [{pull_only}])".format({
		"inputs": ", ".join(inputs.map(func(pair): return '["{0}", {1}]'.format([pair[0], pair[1].serialize_gdscript()]))),
		"outputs": ", ".join(outputs.keys().map(func(key): return '"{0}": {1}'.format([key, outputs[key].serialize_gdscript()]))),
		"code": get_source_code(),
		"pull_only": ", ".join(pull_only.map(func(p): return '"{0}"'.format([p]))),
	})
