@tool
#thumb("reflect.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Reflect", "Reflect a vector.", Card.Type.Effect, [
		NamedInputSlot.new("vector", {"vector": ["Vector2"]}),
		NamedInputSlot.new("normal", {"normal": ["Vector2"]}),
		OutputSlot.new({"vector": ["Vector2"]})
	])

var _vector: Vector2
var _normal: Vector2

func vector(vector: Vector2):
	_vector = vector
	do()

func normal(normal: Vector2):
	_normal = normal
	do()

func do():
	if _vector != null and _normal != null and _normal != Vector2.ZERO:
		invoke_output("vector", [_vector.reflect(_normal)])
