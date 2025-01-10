@tool
#thumb("Remove")
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete", "Delete a node.", Card.Type.Effect)

func invoke0():
	if connected(): connected().queue_free()

func invoke1(obj):
	if connected(): connected().queue_free()
