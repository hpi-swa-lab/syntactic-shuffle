@tool
#thumb("sensor_entered.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Object Sensor", "Emits a signal when detecting an object that has health.", Card.Type.Trigger, [
		ObjectInputSlot.create("object_sensor"),
		OutputSlot.create(1)
	])
	var current_object = get_object_input()
	if current_object:
		current_object.connect("detected", on_detected)
	get_object_input_slot().on_connect = func(object: Node):
		object.connect("detected", on_detected)
	get_object_input_slot().on_disconnect = func(object: Node):
		object.disconnect("detected", on_detected)

func on_detected(object):
	get_output_slot().invoke(self, [object.global_position])
