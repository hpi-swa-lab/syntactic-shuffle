@tool
#thumb("hack.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Hack", "Inspect the brain.", Card.Type.Trigger, [
		ObjectInputSlot.create("hackable")
	])
	get_object_input_slot().on_connect = func (obj):
		print("ASD")
		obj.show_brain(true)
	get_object_input_slot().on_disconnect = func (obj): obj.show_brain(false)
