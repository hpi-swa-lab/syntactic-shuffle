@tool
#thumb("PreviewSun")
extends Card

@export var method: String = ""

func _ready() -> void:
	super._ready()
	setup("Method", "Invoke any method.", Card.Type.Effect)

func invoke0():
	connected().call(method)

func invoke1(arg):
	connected().call(method, arg)
