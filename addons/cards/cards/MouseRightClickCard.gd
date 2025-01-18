@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Mouse Right Click", "Emits signals when the mouse right click is pressed.", "right_click.png", CardVisual.Type.Trigger, [
		OutputSlot.new({"default": [], "vector": ["Vector2"]})
	])


func _process(delta: float) -> void:
	super._process(delta)
	
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("ui_right_click"):
		invoke_output("default", [])
		# FIXME needs to act on the main viewport
		invoke_output("vector", [get_global_mouse_position()])
