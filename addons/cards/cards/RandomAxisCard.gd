@tool
#thumb("RandomNumberGenerator.svg")
extends Card

func _ready() -> void:
	super._ready()
	setup("Random Axis Output", "Emits signals for random inputs on the four axes.", Card.Type.Trigger, [
		OutputSlot.new({"vector": ["Vector2"]})
	])

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	
	invoke_output("vector", [Vector2.UP.rotated(randf() * PI * 2)])
