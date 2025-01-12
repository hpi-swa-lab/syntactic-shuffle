@tool
#thumb("press_F.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Respect", "", Card.Type.Trigger, [])
