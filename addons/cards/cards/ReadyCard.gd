@tool
#thumb("Joypad")
extends Card

func _ready() -> void:
	super._ready()
	setup("Ready", "Emits a signal when this card appears.", Card.Type.Trigger)
	trigger0()
