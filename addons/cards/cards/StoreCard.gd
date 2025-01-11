@tool
#thumb("CylinderMesh")
extends Card

var value: Variant = null

func _ready() -> void:
	super._ready()
	setup("Store", "Stores data. Emits data when updated.", Card.Type.Store, [])
