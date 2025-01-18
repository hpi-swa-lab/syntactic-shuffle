@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Spawn", "Spawn a scene.", "spawner.png", CardVisual.Type.Effect, [
		InputSlot.new({"trigger": []}),
		OutputSlot.new({"spawn": ["spawn"]})
	])

func trigger():
	invoke_output("spawn", [])
