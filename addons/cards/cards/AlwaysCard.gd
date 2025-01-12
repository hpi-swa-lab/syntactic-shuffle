@tool
#thumb("always.png")
extends Card

func _ready() -> void:
	super._ready()
	
	setup("Always",
		"Trigger a singal every frame.",
		Card.Type.Effect,
		[OutputSlot.create(0)])

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint():
		return
	
	invoke_output([])
