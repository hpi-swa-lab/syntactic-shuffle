@tool
#thumb("mouse_position.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Mouse Position", "Continuosly emits signals for the current mouse position.", Card.Type.Trigger, [OutputSlot.create(1)])


func _process(delta: float) -> void:
	super._process(delta)
	
	if Engine.is_editor_hint():
		return
	
	get_output_slot().invoke(self, [get_global_mouse_position()])
