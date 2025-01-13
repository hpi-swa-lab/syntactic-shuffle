@tool
#thumb("clock.png")
extends Card

@export var delay_seconds: float = 1.0:
	get: return delay_seconds
	set(v):
		delay_seconds = v
		delay_seconds_ui.set_value_no_signal(v)

var delay_seconds_ui = SpinBox.new()
var current_elapsed_time = 0.0

func _init() -> void:
	delay_seconds_ui.prefix = "Timer: "
	delay_seconds_ui.suffix = "s"
	delay_seconds_ui.max_value = 1e8
	delay_seconds_ui.custom_arrow_step = 0.1
	delay_seconds_ui.step = 0.01
	delay_seconds_ui.value_changed.connect(func (v): delay_seconds = v)

func _ready() -> void:
	super._ready()
	setup("Delay",
		"Delay for a given time and then forward the inputs.",
		Card.Type.Effect,
		[InputSlot.new({"any": ["*"]}), OutputSlot.new({"any": ["*"]})],
		[delay_seconds_ui])

func generic_called(method, args):
	await get_tree().create_timer(delay_seconds).timeout
	invoke_output(method, args)
