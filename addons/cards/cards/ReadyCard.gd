@tool
#thumb("Joypad")
extends Card

func _ready() -> void:
	super._ready()
	var output = Card.OutputSlot.new(0)
	setup("Ready", "Emits a signal when this card first appears.", Card.Type.Trigger, [output])
	output.invoke(self)
