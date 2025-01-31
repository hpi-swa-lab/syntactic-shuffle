@tool
extends Card
class_name CellCard

var out_card: OutCard

static func create(name: String, type: String, data: Variant):
	var c = CellCard.new()
	c.data_name = name
	c.type = type
	c.data = data
	c.default = data
	return c

@export var default = null

@export var data_name: String

@export var data: Variant = null:
	get: return data
	set(v):
		data = v
		if update_ui_func: update_ui_func.call(v)
@export var type: String = "":
	get: return type
	set(v):
		type = v
		if out_card:
			if v:
				out_card.has_static_signature = true
				out_card.signature = Signature.TypeSignature.new(v)
			else:
				out_card.has_static_signature = false
var update_ui_func = null

func can_edit(): return false

func v():
	title("Data Cell")
	description("Store a piece of data.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF1JREFUOI3tk0sOACEIQ6nx/lfurDBVM4qfpd0ZykslAJJ2oqwPACEaSXQAANTCSOpNq82ewNOmaNOfCiD6/9ZbZqCxZlJvbgvRFK57M3iAQ8DKDpjVqw89551r/AAr3TMjmzBkfAAAAABJRU5ErkJggg==")
	
	var data_name_edit = LineEdit.new()
	data_name_edit.text = data_name
	data_name_edit.text_changed.connect(func(): data_name = data_name_edit.text)
	data_name_edit.placeholder_text = "Name"
	ui(data_name_edit)
	
	var type_edit = LineEdit.new()
	type_edit.text = type
	type_edit.text_changed.connect(func(): type = type_edit.text)
	type_edit.placeholder_text = "Type"
	ui(type_edit)
	
	var default_edit = LineEdit.new()
	default_edit.text = str(default)
	default_edit.text_changed.connect(func(): pass) # TODO
	default_edit.placeholder_text = "Default"
	ui(default_edit)

func s():
	out_card = OutCard.remember([data], Signature.TypeSignature.new(type))
	# refresh type info
	self.type = type
	
	var code_card = CodeCard.create([["arg", cmd("store", any())]], {"out": any()}, func (card, arg):
		data = arg
		card.output("out", [data]))
	code_card.c(out_card)
	
	var override_card = InCard.data(cmd("store", any()))
	override_card.c_named("arg", code_card)
	
	var trigger_code_card = CodeCard.create([], {"out": any()}, func (card): card.output("out", [data]))
	trigger_code_card.c(out_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(trigger_code_card)

func serialize_constructor():
	return "{0}.create(\"{1}\", \"{2}\", {3})".format([get_card_name(), type, default])

func get_extra_ui() -> Array[Control]:
	match type:
		"Vector2":
			var x = get_number_input()
			if data != null: x.value = data.x
			x.value_changed.connect(func(v): data.x = v)
			var y = get_number_input()
			if data != null: y.value = data.y
			y.value_changed.connect(func(v): data.y = v)
			update_ui_func = func(val):
				y.set_value_no_signal(val.y)
				x.set_value_no_signal(val.x)
			return [x, y]
		"float":
			var n = get_number_input()
			if data != null: n.value = data
			n.value_changed.connect(func(v): data = v)
			update_ui_func = func(val): n.set_value_no_signal(val)
			return [n]
		"bool":
			var b = CheckButton.new()
			if data != null: b.button_pressed = data
			b.toggled.connect(func(b): data = b)
			update_ui_func = func(v): b.set_pressed_no_signal(v)
			return [b]
		"string":
			var e = TextEdit.new()
			if data != null: e.text = data
			e.text_changed.connect(func (): data = e.text)
			update_ui_func = func(v): e.text = v
			return e
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
