@tool
extends Card
class_name CodeCard

## Returns the source code of the anonymous function at the given index in the source file.
static func fetch_source_code_of(path: String, index: int):
	if not _source_code_cache.has(path):
		_source_code_cache[path] = _extract_anonymous_functions(FileAccess.get_file_as_string(path))
	return _source_code_cache[path][index]
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

func v():
	title("Code")
	description("Run some code.")
	icon(preload("res://addons/cards/icons/code.png"))

func s():
	for output in outputs:
		OutCard.static_signature(outputs[output])
	
	for pair in inputs:
		NamedInCard.named_data(pair[0], pair[1])

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
	return fetch_source_code_of(
		parent.get_script().resource_path,
		parent.cards.filter(func (c): return c is CodeCard).find(self))

func serialize_constructor():
	return "CodeCard.create([{inputs}], {{outputs}}, {code}, [{pull_only}])".format({
		"inputs": ", ".join(inputs.map(func(pair): return '["{0}", {1}]'.format([pair[0], pair[1].serialize_gdscript()]))),
		"outputs": ", ".join(outputs.keys().map(func(key): return '"{0}": {1}'.format([key, outputs[key].serialize_gdscript()]))),
		"code": get_source_code(),
		"pull_only": ", ".join(pull_only.map(func(p): return '"{0}"'.format([p]))),
	})
