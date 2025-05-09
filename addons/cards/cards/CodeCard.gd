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

static func create_default():
	@warning_ignore("unused_parameter")
	return CodeCard.new([], [["out", Signature.TypeSignature.new("")]], func(card, out): pass , [], "func(card, out): out.call(null)")

static func create(inputs: Array[Array], outputs: Array[Array], process: Callable, pull_only = []):
	var c = CodeCard.new(inputs, outputs, process, pull_only)
	return c

func _init(inputs: Array[Array], outputs: Array[Array], process: Callable, pull_only = [], source_code = ""):
	self.outputs = outputs
	self.process = process
	self.inputs = inputs
	self.pull_only = pull_only
	self.source_code = source_code
	super._init()
	get_source_code()

func clone():
	return get_script().new(inputs, outputs, process, pull_only, source_code)

var outputs: Array[Array]
var process: Callable
var inputs: Array[Array]
var pull_only: Array

var error_label: Label

var source_code: String = "":
	get: return source_code
	set(v):
		source_code = v
		if visual: description(v.substr(0, 150))

func create_expanded(): return load("res://addons/cards/code_editor.tscn").instantiate()

func v():
	title("Code")
	icon(preload("res://addons/cards/icons/code.png"))
	source_code = source_code
	
	visual.short_description()
	
	error_label = Label.new()
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	error_label.add_theme_color_override("font_color", Color.DARK_RED)
	ui(error_label)

func s():
	for pair in inputs:
		NamedInCard.new(pair[0], pair[1])
	
	for pair in outputs:
		StaticOutCard.new(pair[0], pair[1])

func rebuild_inputs_outputs():
	for card in cards: card.queue_free()
	cards.clear()
	build_cards_list()

func setup_finished():
	super.setup_finished()
	get_source_code()

func cycles_allowed_for(name: String): return pull_only.has(name)

var _current_error: Error = null
func report_error(s: Error):
	if _current_error:
		_current_error.close.disconnect(close_error)
	_current_error = s
	s.close.connect(close_error)
	if error_label: error_label.text = s.get_message()
	if visual and visual.editor:
		visual.editor.report_error(s)
func close_error():
	if error_label: error_label.text = ""

var pending_invoke: Dictionary[Invocation, Dictionary] = {}
func _get_pending_dict():
	var r = {}
	for pair in inputs: r[pair[0]] = []
	return r
func clear_pending():
	pending_invoke.clear()

func invoke(args: Array, signature: Signature, invocation: Invocation, named = "", source_out = null):
	if pull_only.has(named): return
	var input = get_input(named)
	if not signature.compatible_with(input.signature): return
	
	if not pending_invoke.has(invocation): pending_invoke.set(invocation, _get_pending_dict())
	var pending := pending_invoke.get(invocation)
	if not pull_only.has(named): pending[named].push_back(Invocation.Remembered.new(args, signature))
	
	var combined_args = []
	var signatures = []
	var has_at_least_one_non_pull = false
	for pair in inputs:
		if pending[pair[0]].is_empty():
			if not pair[1].provides_data(): continue
			var card = get_input(pair[0])
			# FIXME using GLOBAL invocation -- see comment in OutCard
			var remembered = card.get_remembered(Invocation.GLOBAL)
			# not enough args yet
			if remembered == null: return
			combined_args.append_array(remembered.get_remembered_value(Invocation.GLOBAL))
			signatures.push_back(remembered.get_remembered_signature(Invocation.GLOBAL))
		else:
			has_at_least_one_non_pull = has_at_least_one_non_pull or not pull_only.has(pair[0])
			combined_args.append_array(pending[pair[0]][0].args)
			signatures.push_back(pending[pair[0]][0].signature)
	if not has_at_least_one_non_pull: return
	# success! we got enough, so we can pop for this invocation now
	for pair in inputs:
		if not pending[pair[0]].is_empty(): pending[pair[0]].pop_front()
	# FIXME very noisy -- add extra protocol?
	# for out in pulled_remembered: out.mark_activated(parent)
	if process.get_argument_count() - outputs.size() - 1 != combined_args.size():
		push_error("Need {0} arguments to invoke (received {1}).".format([process.get_argument_count(), combined_args.size() + outputs.size() + 1]))
		report_error(Error.Generic.new("Need {0} arguments to invoke (received {1}).".format([process.get_argument_count(), combined_args.size()])))
		return
	
	if source_out: mark_activated(source_out, args)
	
	if should_hyper_invoke(signatures): hyper_invoke(combined_args, signatures, invocation)
	else:
		for i in range(outputs.size() - 1, -1, -1):
			combined_args.push_front(_output.bind(invocation, outputs[i][0], signatures))
		combined_args.push_front(self)
		process.callv(combined_args)

func should_hyper_invoke(signatures):
	for i in range(signatures.size()):
		if signatures[i].has_iterator() and not inputs[i][1].has_iterator():
			return true
	return false

# Inspiration from https://github.com/jmoenig/Snap/blob/724297b6391f3d8d964a45b2bc7d0ea29cb8c75e/src/threads.js#L4807
func hyper_invoke(args: Array, signatures: Array, invocation: Invocation):
	assert(signatures.filter(func(s): return s.has_iterator()).size() == 1, "TODO no support yet for more than one iterator")
	var iterator_index = -1
	for i in range(0, signatures.size()):
		if signatures[i].has_iterator(): iterator_index = i
	var list = args[iterator_index]
	
	var result = {}
	var count = {}
	for out in outputs:
		result[out[0]] = range(0, list.size())
		count[out[0]] = 0
	var report_result = func(arg, invocation, name, index):
		result[name][index] = arg
		count[name] += 1
		if count[name] == list.size():
			_output(result[name], invocation, name, signatures)
	
	for i in range(0, list.size()):
		var item = list[i]
		args[iterator_index] = item
		var combined_args = [self]
		for pair in outputs: combined_args.push_back(report_result.bind(invocation, pair[0], i))
		combined_args.append_array(args)
		process.callv(combined_args)

func _output(arg: Variant, invocation: Invocation, name: String, in_signatures: Array):
	var output = get_output(name)
	var out_sig
	if output.output_signatures.size() != 1:
		var compat = output.static_signature.make_concrete(Signature.sig_array(in_signatures))
		assert(compat.size() == 1)
		for s in output.output_signatures:
			if s.eq(compat[0]): out_sig = s
	else:
		out_sig = output.output_signatures[0]
	assert(out_sig)
	var args = [arg] if out_sig.provides_data() else []
	output.invoke(args, out_sig, invocation, "", output)

func get_output(name: String) -> OutCard:
	for o in get_outputs():
		if o.output_name == name: return o
	return null

func get_input(name: String) -> InCard:
	for o in get_inputs():
		if o.input_name == name: return o
	return null

func get_source_code():
	if not source_code:
		var index = parent.cards_parent.get_children().filter(func(c): return c is CodeCard).find(self)
		source_code = fetch_source_code_in(parent.get_script().source_code, index)
	return source_code

func serialize_constructor():
	return "CodeCard.create([{inputs}], [{outputs}], {code}, [{pull_only}])".format({
		"inputs": ", ".join(inputs.map(func(pair): return '["{0}", {1}]'.format([pair[0], pair[1].serialize_gdscript()]))),
		"outputs": ", ".join(outputs.map(func(pair): return '["{0}", {1}]'.format([pair[0], pair[1].serialize_gdscript()]))),
		"code": get_source_code(),
		"pull_only": ", ".join(pull_only.map(func(p): return '"{0}"'.format([p]))),
	})
