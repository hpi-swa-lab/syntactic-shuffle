@tool
#thumb("left_click.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Mouse Left Click", "Emits signals when the mouse left click is pressed.", Card.Type.Trigger, [OutputSlot.create(0)])


func _process(delta: float) -> void:
	super._process(delta)
	
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed("ui_left_click"):
		print("left click")
		get_output_slot().invoke(self, [])
