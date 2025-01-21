@tool
extends Card
class_name CellCard

var out_card: OutCard

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

func s():
	title("Data Cell")
	description("Store or piece of data.")
	icon("number.png")
	
	out_card = OutCard.remember([data], Signature.TypeSignature.new(type))
	# refresh type info
	self.type = type
	
	var code_card = CodeCard.create([["arg", cmd("store", any())]], {"out": any()}, func (card, arg):
		data = arg
		card.output("out", [data]))
	code_card.c(out_card)
	
	var override_card = InCard.command("store", any())
	override_card.c_named("arg", code_card)
	
	var trigger_code_card = CodeCard.create([], {"out": any()}, func (card): card.output("out", [data]))
	trigger_code_card.c(out_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(trigger_code_card)

func get_extra_ui() -> Array[Control]:
	match type:
		"Vector2":
			var x = get_number_input()
			if data: x.value = data.x
			x.value_changed.connect(func(v): data.x = v)
			var y = get_number_input()
			if data: y.value = data.y
			y.value_changed.connect(func(v): data.y = v)
			update_ui_func = func(val):
				y.set_value_no_signal(val.y)
				x.set_value_no_signal(val.x)
			return [x, y]
		"float":
			var n = get_number_input()
			if data: n.value = data
			n.value_changed.connect(func(v): data = v)
			update_ui_func = func(val): n.set_value_no_signal(val)
			return [n]
		"bool":
			var b = CheckButton.new()
			if data != null: b.pressed = data
			b.toggled.connect(func(b): data = b)
			update_ui_func = func(v): b.set_pressed_no_signal(v)
			return [b]
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
