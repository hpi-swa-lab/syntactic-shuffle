@tool
extends Card
class_name CellCard

var out_card: OutCard
var in_card: InCard
var signature_out_card: OutCard

static func create_default():
	return CellCard.new("value", "float", 0.0)

static func create(name: String, type: String, data: Variant):
	var c = CellCard.new(name, type, data)
	return c

func _init(name: String, type: String, data: Variant):
	self.data_name = name
	self.type = type
	self.data = data
	self.default = data
	assert(data == null or Signature.type_signature(typeof(data)) == type)
	super._init()

func clone():
	return get_script().new(data_name, type, default)

@export var default = null

@export var data_name: String

@export var data: Variant = null:
	get: return data
	set(v):
		data = v
		if out_card: out_card.remember(out_card.static_signature, [data], Invocation.GLOBAL)
		if update_ui_func: update_ui_func.call(v)
		update_out_type()
@export var type: String = "":
	get: return type
	set(v):
		type = v
		update_out_type()
var update_ui_func = null

func can_edit(): return false
func can_be_trigger(): return false

func update_out_type():
	var t = Signature.TypeSignature.new(Signature.type_signature(typeof(data)) if data != null and type == "Variant" else type)
	if in_card and in_card.signature.arg is Signature.TypeSignature and t.type == in_card.signature.arg.type: return
	
	if in_card: in_card.signature = Signature.CommandSignature.new("store", t)
	if out_card: out_card.override_signature([t] as Array[Signature])
	if signature_out_card: signature_out_card.invoke([t], cmd("signature_changed", t("Signature")), Invocation.new())
	
	start_propagate_incoming_connected()

func v():
	title("Data Cell")
	description("Store a piece of data.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF1JREFUOI3tk0sOACEIQ6nx/lfurDBVM4qfpd0ZykslAJJ2oqwPACEaSXQAANTCSOpNq82ewNOmaNOfCiD6/9ZbZqCxZlJvbgvRFK57M3iAQ8DKDpjVqw89551r/AAr3TMjmzBkfAAAAABJRU5ErkJggg==")
	
	var data_name_edit = LineEdit.new()
	data_name_edit.text = data_name
	data_name_edit.text_changed.connect(func(s):
		data_name = s
		get_editor().card_content_edited(self))
	data_name_edit.placeholder_text = "Name"
	ui(data_name_edit)
	
	var type_edit = LineEdit.new()
	type_edit.text = type
	type_edit.text_changed.connect(func(s):
		type = s
		get_editor().card_content_edited(self))
	type_edit.placeholder_text = "Type"
	ui(type_edit)
	
	var confirm_default = Label.new()
	confirm_default.text = "Press enter to confirm."
	confirm_default.add_theme_color_override("font_color", Color.BLACK)
	confirm_default.visible = false
	
	var default_edit = LineEdit.new()
	default_edit.text = Signature.data_to_expression(default)
	default_edit.text_changed.connect(func (s): confirm_default.visible = true)
	default_edit.text_submitted.connect(func(s):
		confirm_default.visible = false
		default = G.eval_expression(s)
		get_editor().card_content_edited(self)
		data = default)
	default_edit.placeholder_text = "Default"
	ui(default_edit)
	
	ui(confirm_default)

func s():
	out_card = StaticOutCard.new("out", Signature.TypeSignature.new(type), true)
	out_card.remember(out_card.static_signature, [data], Invocation.GLOBAL)
	#signature_out_card = StaticOutCard.new(cmd("signature_changed", t("Signature")))
	
	var code_card = CodeCard.create([["arg", cmd("store", any())]], [["out", any()]], func(card, out, arg):
		data = arg
		update_out_type()
		out.call(data))
	code_card.c(out_card)
	
	in_card = InCard.data(cmd("store", any()))
	in_card.c_named("arg", code_card)
	
	var trigger_code_card = CodeCard.create([["trigger", trg()]], [["out", any()]], func(card, out): out.call(data))
	trigger_code_card.c(out_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c_named("trigger", trigger_code_card)
	
	# refresh type info
	self.type = type

func serialize_constructor():
	return "{0}.create(\"{1}\", \"{2}\", {3})".format([card_name, data_name, type, Signature.data_to_expression(default)])

func change_data_ui(cb):
	return func(v):
		cb.call(v)
		get_editor().card_content_edited(parent)

func get_extra_ui() -> Array[Control]:
	match type:
		"Vector2":
			var x = get_number_input()
			if data != null: x.value = data.x
			x.value_changed.connect(change_data_ui(func(v): data.x = v))
			var y = get_number_input()
			if data != null: y.value = data.y
			y.value_changed.connect(change_data_ui(func(v): data.y = v))
			update_ui_func = func(val):
				y.set_value_no_signal(val.y)
				x.set_value_no_signal(val.x)
			return [x, y]
		"float":
			var n = get_number_input()
			if data != null: n.value = data
			n.value_changed.connect(change_data_ui(func(v): data = v))
			update_ui_func = func(val): n.set_value_no_signal(val)
			return [n]
		"int":
			var n = get_number_input()
			n.step = 1
			if data != null: n.value = data
			n.value_changed.connect(change_data_ui(func(v): data = int(v)))
			update_ui_func = func(val): n.set_value_no_signal(val)
			return [n]
		"bool":
			var b = CheckButton.new()
			if data != null: b.button_pressed = data
			b.toggled.connect(change_data_ui(func(b): data = b))
			update_ui_func = func(v): b.set_pressed_no_signal(v)
			return [b]
		"String":
			var e = TextEdit.new()
			e.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
			e.scroll_fit_content_height = true
			e.caret_blink = true
			e.add_theme_font_size_override("font_size", 8)
			if data != null: e.text = data
			e.text_changed.connect(func():
				data = e.text
				get_editor().card_content_edited(parent))
			update_ui_func = func(v): if e.text != v: e.text = v
			return [e]
		_:
			return []

func get_number_input(prefix = ""):
	var number_ui = SpinBox.new()
	number_ui.prefix = prefix
	number_ui.custom_arrow_step = 0.1
	number_ui.step = 0.01
	number_ui.min_value = -1e8
	number_ui.max_value = 1e8
	return number_ui
