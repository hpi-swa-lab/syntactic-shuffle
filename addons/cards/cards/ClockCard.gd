@tool
extends Card

@export var delay_seconds: float = 1.0:
	get: return delay_seconds
	set(v):
		delay_seconds = v
		delay_seconds_ui.set_value_no_signal(v)
		editor_sync_prop("delay_seconds")

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
	
	setup("Clock",
		"Trigger a singal after a specified time.",
		"clock.png",
		Card.Type.Effect,
		[OutputSlot.new({"default": []})],
		[delay_seconds_ui])

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	
	current_elapsed_time += delta
	if delay_seconds != null and current_elapsed_time >= delay_seconds:
		invoke_output("default", [])
		current_elapsed_time -= delay_seconds
