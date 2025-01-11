#thumb("clock.png")
@tool
extends Card

var delay_seconds = SpinBox.new()
var current_elapsed_time = 0.0

func _ready() -> void:
	super._ready()
	delay_seconds.prefix = "Timer: "
	delay_seconds.suffix = "s"
	delay_seconds.value = 5
	delay_seconds.step = 0.2
	
	setup("Clock",
		"Trigger a singal after a specified time.",
		Card.Type.Effect,
		[OutputSlot.create(0)],
		delay_seconds)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	current_elapsed_time += delta
	if delay_seconds.value != null and current_elapsed_time >= delay_seconds.value:
		invoke_output([])
		current_elapsed_time -= delay_seconds.value
