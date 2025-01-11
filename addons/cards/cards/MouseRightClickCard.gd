@tool
#thumb("right_click.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Mouse Right Click", "Emits signals when the mouse right click is pressed.", Card.Type.Trigger, [OutputSlot.create(0)])


func _process(delta: float) -> void:
	super._process(delta)
	
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("ui_right_click"):
		get_output_slot().invoke(self, [])
