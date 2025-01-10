@tool
#thumb("Remove")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete", "Delete a node.", Card.Type.Effect)

func invoke0():
	connected().queue_free()
