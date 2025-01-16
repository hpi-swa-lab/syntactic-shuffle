@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Mouse Position", "Continuosly emits signals for the current mouse position.", "mouse_position.png", Card.Type.Trigger, [
		OutputSlot.new({"vector": ["Vector2"]})
	])


func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	
	# FIXME needs to act on the main viewport
	invoke_output("vector", [get_global_mouse_position()])
