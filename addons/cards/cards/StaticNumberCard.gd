#thumb("clock.png")
@tool
extends Card

var magic_number_chooser = SpinBox.new()

func _ready() -> void:
	super._ready()
	magic_number_chooser.prefix = "Magic Number: "
	magic_number_chooser.min_value = -1000
	magic_number_chooser.max_value = 1000
	magic_number_chooser.value = 21
	magic_number_chooser.step = 1
	
	setup("Magic Number",
		"On ",
		Card.Type.Effect,
		[InputSlot.create(0), OutputSlot.create(1)],
		magic_number_chooser)
	
	on_invoke_input(invoke)
	
func invoke() -> void:
	if Engine.is_editor_hint():
		return
	
	invoke_output([magic_number_chooser.value])
