@tool
#thumb("Time")
extends Card

var delay_seconds = SpinBox.new()

func _ready() -> void:
	super._ready()
	delay_seconds.prefix = "Delay: "
	delay_seconds.suffix = "s"
	delay_seconds.value = 1
	setup("Delay",
		"Delay for a given time and then forward the inputs.",
		Card.Type.Effect,
		[OutputSlot.create(1), InputSlot.create(1)],
		delay_seconds)
	on_invoke_input(invoke)

func invoke(obj):
	await get_tree().create_timer(1).timeout
	invoke_output([obj])
