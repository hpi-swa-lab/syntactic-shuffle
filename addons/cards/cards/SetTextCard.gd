@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Set Text", "Set the text of a label.", "trigger.png", CardVisual.Type.Trigger, [
		InputSlot.new({
			"set_vector2_text": ["Vector2"],
			"set_float_text": ["float"],
			"set_int_text": ["int"],
			"set_array_text": ["Array"],
			"set_text": ["String"]
		}),
		ObjectInputSlot.new()
	])

func set_vector2_text(v: Vector2): set_text(str(v))
func set_float_text(num: float): set_text(str(num))
func set_int_text(num: int): set_text(str(num))
func set_array_text(array: Array): set_text(str(array))
func set_text(text: String):
	var obj = get_object_input()
	if obj and "text" in obj:
		obj.text = text
		activate_object_input()
