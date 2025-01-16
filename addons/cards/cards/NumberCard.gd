@tool
extends Card

@export var number: float = 0.0:
	get: return number
	set(v):
		if number == v: return
		number = v
		number_ui.set_value_no_signal(v)
		editor_sync_prop("number")

var number_ui = SpinBox.new()

func _init() -> void:
	number_ui.prefix = "x: "
	number_ui.set_value_no_signal(number)
	number_ui.custom_arrow_step = 0.1
	number_ui.step = 0.01
	number_ui.min_value = -1e8
	number_ui.max_value = 1e8
	number_ui.value_changed.connect(func (v): number = v)

func _ready() -> void:
	super._ready()
	
	setup("Number", "Stores a number. Continuously outputs it, unless an input is connected.", "number.png", Card.Type.Trigger,
		[
			OutputSlot.new({"number": ["float"]}),
			InputSlot.new({
				"trigger": [],
				"increment": ["increment"],
				"override": ["float"]
			})
		],
		[number_ui])

func override(num: float):
	number = num
	trigger()

func increment():
	number += 1
	trigger()

func trigger():
	invoke_output("number", [number])

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	
	if connections["__input"].is_empty():
		trigger()
