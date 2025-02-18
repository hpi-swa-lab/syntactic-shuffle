extends PanelContainer
class_name CodeEditor

var code_card: CodeCard

func attach_cards(card: CodeCard, size: Vector2):
	assert(card is CodeCard)
	
	self.code_card = card
	%Unsaved.visible = false
	
	for input in card.cards:
		if input is NamedInCard:
			%inputs.add_child(build_field(input.input_name, input))
	for i in range(card.outputs.size()):
		var output = card.get_outputs()[i]
		%outputs.add_child(build_field(card.outputs[i][0], output))
	
	var regex = RegEx.new()
	regex.compile(r"^\s*func\s*\(.+\):[^\S\n]*\n?")
	
	%code.text = dedent(regex.sub(card.get_source_code(), ""))
	fake_a_godot_highlighter()
	
	update_function_signature()
	_resize()

func detach_cards(): pass

func _resize():
	custom_minimum_size = %Content.get_combined_minimum_size()

var _current_error: Error = null
func report_error(s: Error):
	if _current_error:
		_current_error.close.disconnect(close_error)
	_current_error = s
	s.close.connect(close_error)
	%Error.text = s.get_message()
	var ui = s.fix_ui()
	if %ErrorUI.get_child_count() > 0: %ErrorUI.remove_child(%ErrorUI.get_child(0))
	if ui: %ErrorUI.add_child(ui)

func close_error():
	%Error.text = ""
	if %ErrorUI.get_child_count() > 0: %ErrorUI.remove_child(%ErrorUI.get_child(0))

func get_current_inputs():
	return Array(%inputs.get_children().map(func(box): return [box.get_meta("name").text, box.get_meta("signature").signature]), TYPE_ARRAY, "", null)

func get_current_outputs():
	return Array(%outputs.get_children().map(func(box): return [box.get_meta("name").text, box.get_meta("signature").signature]), TYPE_ARRAY, "", null)

func get_function_signature():
	var inputs = ["card"]
	inputs.append_array(get_current_outputs().map(func(pair): return pair[0]))
	inputs.append_array(get_current_inputs().filter(func(pair): return pair[1].provides_data()).map(func(pair): return pair[0]))
	return "func ({0}):".format([", ".join(inputs)])

func update_function_signature():
	%FunctionSignature.text = get_function_signature()
	save_inputs_outputs()

func build_field(name: String, card: Card):
	var box = VBoxContainer.new()
	
	var label = LineEdit.new()
	label.text = name
	label.placeholder_text = "Input..." if card is InCard else "Output..."
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color.BLACK)
	box.add_child(label)
	box.set_meta("name", label)
	
	if card is InCard:
		label.text_changed.connect(func(s):
			card.rename(s)
			update_function_signature()
			save_pull_list())
	else:
		label.text_changed.connect(func(s):
			update_function_signature()
			save_inputs_outputs())
	
	var sig = VBoxContainer.new()
	sig.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var editor = preload("res://addons/cards/signature/signature_edit.tscn").instantiate()
	editor.signature = card.signature if card is InCard else card.static_signature
	editor.on_edit.connect(func(s):
		update_function_signature()
		if card is InCard: card.signature = s
		else: card.static_signature = s)
	box.set_meta("signature", editor)
	
	sig.add_child(editor)
	
	var row = HBoxContainer.new()
	row.add_child(sig)
	var buttons = VBoxContainer.new()
	var remove = Button.new()
	remove.focus_mode = Control.FOCUS_CLICK
	remove.text = "×"
	remove.pressed.connect(func():
		box.queue_free()
		await get_tree().process_frame
		update_function_signature())
	buttons.add_child(remove)
	var up = Button.new()
	up.text = "↑"
	up.focus_mode = Control.FOCUS_CLICK
	up.pressed.connect(func():
		box.get_parent().move_child(box, box.get_index() - 1)
		update_function_signature())
	buttons.add_child(up)
	var down = Button.new()
	down.focus_mode = Control.FOCUS_CLICK
	down.text = "↓"
	down.pressed.connect(func():
		box.get_parent().move_child(box, box.get_index() + 1)
		update_function_signature())
	buttons.add_child(down)
	row.add_child(buttons)
	
	box.add_child(row)
	
	if card is InCard:
		var pull = CheckBox.new()
		pull.set_meta("input_name", label)
		pull.text = "Pull only"
		pull.add_theme_color_override("font_color", Color.BLACK)
		pull.add_theme_color_override("font_pressed_color", Color.BLACK)
		pull.add_theme_color_override("font_focus_color", Color.BLACK)
		pull.add_theme_color_override("font_hover_color", Color.BLACK)
		pull.add_theme_color_override("font_hover_pressed_color", Color.BLACK)
		pull.button_pressed = card.parent.pull_only.has(name)
		pull.pressed.connect(func(): save_pull_list())
		sig.add_child(pull)
		box.set_meta("pull_only", pull)
	
	box.add_child(HSeparator.new())
	
	return box

func _on_add_input_pressed() -> void:
	%inputs.add_child(build_field("name", code_card.add_card(NamedInCard.named_data("names", Signature.TypeSignature.new("")))))
	save_inputs_outputs()
	update_function_signature()
	_resize()

func _on_add_selected_pressed() -> void:
	var names = {}
	var connections = []
	for selected in code_card.get_editor().get_selection():
		if selected == code_card: continue
		var sig = selected.output_signatures
		# FIXME picking first
		sig = sig[0]
		
		var valid = RegEx.new()
		valid.compile(r"[^A-Za-z0-9_]")
		var name = valid.sub(sig.get_description(), "", true).to_snake_case()
		var counter = names.get(name, 0)
		names.set(name, counter + 1)
		if counter > 0: name = name + "_" + str(counter)
		
		%inputs.add_child(build_field(name, code_card.add_card(NamedInCard.named_data(name, sig))))
		connections.push_back([name, selected])
	
	update_function_signature()
	_resize()
	for pair in connections: pair[1].c_named(pair[0], code_card)

func add_output(name = "out", signature = null) -> void:
	if not signature: signature = Signature.TypeSignature.new("")
	%outputs.add_child(build_field(name, code_card.add_card(StaticOutCard.new(name, signature))))
	save_inputs_outputs()
	_resize()

func _on_code_gui_input(event: InputEvent) -> void:
	if (event is InputEventKey and
		event.pressed and
		not event.is_echo() and
		event.keycode == KEY_S
		and event.ctrl_pressed):
			_on_save_pressed()
			get_viewport().set_input_as_handled()

func _on_save_pressed() -> void:
	if not save_process_callable(): return
	save_inputs_outputs()
	# code_card.visual.expanded = false

func save_pull_list():
	code_card.pull_only = (%inputs.get_children()
		.map(func(c): return c.get_meta("pull_only"))
		.filter(func(c): return c.button_pressed)
		.map(func(c): return c.get_meta("input_name").text))

func save_inputs_outputs():
	code_card.inputs = get_current_inputs()
	code_card.outputs = get_current_outputs()

func save_process_callable():
	var s = GDScript.new()
	var src = get_function_signature() + "\n" + %code.text.indent("\t\t")
	print(src)
	s.source_code = "@tool\nextends Card\nfunc build():\n\treturn {0}".format([src])
	if s.reload() != OK:
		return false
	var obj = Card.new()
	obj.set_script(s)
	code_card.process = obj.build()
	code_card.source_code = src
	%Unsaved.visible = false
	return true

func indent(src: String):
	return "\n".join(Array(src.split("\n")).map(func(l): return "\t" + l if not l.begins_with("func(") else l))

static func dedent(src: String):
	var prefix_length = RegEx.new()
	prefix_length.compile(r"^\s*")
	
	var lines = Array(src.split("\n"))
	var min_indent = 9e8
	var first = true
	for line in lines:
		var m = prefix_length.search(line)
		if m.strings[0].length() == line.length(): continue
		min_indent = min(min_indent, m.strings[0].length())
	
	first = true
	var out = ""
	for line in lines:
		if line.length() > min_indent:
			out += line.substr(min_indent) + "\n"
	
	return out

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

func _on_code_text_changed() -> void:
	%Unsaved.visible = true
