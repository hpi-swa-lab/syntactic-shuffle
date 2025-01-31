extends Panel

var card: CodeCard

func attach_cards(card: CodeCard):
	assert(card is CodeCard)
	
	self.card = card
	
	for input in card.inputs:
		%inputs.add_child(build_field(input[0], input[1], true))
	for output in card.outputs:
		%outputs.add_child(build_field(output, card.outputs[output], false))
	
	%code.text = dedent(card.get_source_code())
	fake_a_godot_highlighter()
	
	_resize()

func detach_cards(): pass

func _resize():
	custom_minimum_size = %Content.get_combined_minimum_size()

func build_field(name: String, signature: Signature, is_input: bool):
	var box = VBoxContainer.new()
	
	var label = LineEdit.new()
	label.text = name
	label.placeholder_text = "Input..." if is_input else "Output..."
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.BLACK)
	box.add_child(label)
	
	var editor = preload("res://addons/cards/signature/signature_edit.tscn").instantiate()
	editor.signature = signature
	box.add_child(editor)
	
	if is_input:
		var pull = CheckBox.new()
		pull.set_meta("input_name", name)
		pull.text = "Pull only"
		pull.add_theme_color_override("font_color", Color.BLACK)
		pull.add_theme_color_override("font_pressed_color", Color.BLACK)
		pull.add_theme_color_override("font_focus_color", Color.BLACK)
		pull.add_theme_color_override("font_hover_color", Color.BLACK)
		pull.add_theme_color_override("font_hover_pressed_color", Color.BLACK)
		pull.button_pressed = card.pull_only.has(name)
		box.add_child(pull)
		box.set_meta("pull_only", pull)
	
	return box

func _on_add_input_pressed() -> void:
	%inputs.add_child(build_field("", Signature.VoidSignature.new(), true))
	_resize()

func _on_add_output_pressed() -> void:
	%outputs.add_child(build_field("", Signature.VoidSignature.new(), false))
	_resize()

func _on_save_pressed() -> void:
	save_process_callable()
	card.pull_only = (%inputs.get_children()
		.map(func (c): return c.get_meta("pull_only"))
		.filter(func (c): return c.button_pressed)
		.map(func (c): return c.get_meta("input_name")))
	card.inputs = Array(%inputs.get_children().map(func(box): return [box.get_child(0).text, box.get_child(1).signature]), TYPE_ARRAY, "", null)
	var outputs = %outputs.get_children().map(func(box): return [box.get_child(0).text, box.get_child(1).signature])
	var o = {}
	for pair in outputs:
		o[pair[0]] = pair[1]
	card.outputs = Dictionary(o, TYPE_STRING, "", null, TYPE_OBJECT, "Object", Signature)
	card.visual.expanded = false

func _on_code_gui_input(event: InputEvent) -> void:
	if (event is InputEventKey and
		event.pressed and
		not event.is_echo() and
		event.keycode == KEY_S):
			_on_save_pressed()

func save_process_callable():
	var s = GDScript.new()
	var src = indent(%code.text)
	s.source_code = "extends Object\nfunc build():\n\treturn {0}".format([src])
	if s.reload() != OK:
		return null
	var obj = Object.new()
	obj.set_script(s)
	card.process = obj.build()
	card.source_code = src

func indent(src: String):
	return "\n".join(Array(src.split("\n")).map(func (l): return "\t" + l if not l.begins_with("func(") else l))

func dedent(src: String):
	return "\n".join(Array(src.split("\n")).map(func (l): return l.substr(1) if l.begins_with("\t") else l))

func fake_a_godot_highlighter():
	var h = CodeHighlighter.new()
	h.color_regions = {
		"\" \"": Color(0.639, 0.082, 0.082),
		"' '": Color(0.639, 0.082, 0.082)
	}
	h.number_color = Color(0.639, 0.082, 0.082)
	h.symbol_color = Color(0.0, 0.0, 1.0)
	h.function_color = Color(0.474, 0.369, 0.149)
	h.member_variable_color = Color(0.0, 0.2, 0.681)
	
	var control_flow_keyword_color = Color(0.686, 0.0, 0.859)
	var keyword_color = Color(0.149, 0.498, 0.6)
	h.keyword_colors = {
		"break": control_flow_keyword_color,
		"continue": control_flow_keyword_color,
		"elif": control_flow_keyword_color,
		"else": control_flow_keyword_color,
		"if": control_flow_keyword_color,
		"for": control_flow_keyword_color,
		"match": control_flow_keyword_color,
		"pass": control_flow_keyword_color,
		"return": control_flow_keyword_color,
		"while": control_flow_keyword_color,
		# operators
		"and": keyword_color,
		"in": keyword_color,
		"not": keyword_color,
		"or": keyword_color,
		# types and values
		"false": keyword_color,
		"float": keyword_color,
		"int": keyword_color,
		"bool": keyword_color,
		"null": keyword_color,
		"PI": keyword_color,
		"TAU": keyword_color,
		"INF": keyword_color,
		"NAN": keyword_color,
		"self": keyword_color,
		"true": keyword_color,
		"void": keyword_color,
		# functions
		"as": keyword_color,
		"assert": keyword_color,
		"await": keyword_color,
		"breakpoint": keyword_color,
		"class": keyword_color,
		"class_name": keyword_color,
		"extends": keyword_color,
		"is": keyword_color,
		"func": keyword_color,
		"preload": keyword_color,
		"signal": keyword_color,
		"super": keyword_color,
		# var
		"const": keyword_color,
		"enum": keyword_color,
		"static": keyword_color,
		"var": keyword_color,
	}
	%code.syntax_highlighter = h
