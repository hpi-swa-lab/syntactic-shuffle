@tool
#thumb("trigger.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Set Text", "Set the text of a label.", Card.Type.Trigger, [
		InputSlot.new({
			"set_float_text": ["float"],
			"set_int_text": ["int"],
			"set_text": ["String"]
		}),
		ObjectInputSlot.new()
	])

func set_float_text(num: float):
	set_text(str(num))

func set_int_text(num: int):
	set_text(str(num))

func set_text(text: String):
	var obj = get_object_input()
	if obj and "text" in obj:
		obj.text = text
		activate_object_input()
