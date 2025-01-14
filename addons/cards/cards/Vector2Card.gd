@tool
#thumb("vector.png")
extends Card

@export var vector: Vector2 = Vector2.ZERO:
	get: return vector
	set(v):
		vector = v
		vector_x.set_value_no_signal(v.x)
		vector_y.set_value_no_signal(v.y)

var vector_x = SpinBox.new()
var vector_y = SpinBox.new()

func _init() -> void:
	vector_x.prefix = "x: "
	vector_x.set_value_no_signal(vector.x)
	vector_x.custom_arrow_step = 0.1
	vector_x.step = 0.01
	vector_x.min_value = -1e8
	vector_x.max_value = 1e8
	vector_x.value_changed.connect(func (v): vector.x = v)
	
	vector_y.prefix = "y: "
	vector_y.set_value_no_signal(vector.y)
	vector_y.custom_arrow_step = 0.1
	vector_y.step = 0.01
	vector_y.min_value = -1e8
	vector_y.max_value = 1e8
	vector_y.value_changed.connect(func (v): vector.y = v)

func _ready() -> void:
	super._ready()
	
	setup("Output 2D Vector", "Continuously outputs the vector, unless an input is connected.", Card.Type.Trigger,
		[OutputSlot.new({"vector": ["Vector2"]}), InputSlot.new({"trigger": []})],
		[vector_x, vector_y])

func trigger():
	invoke_output("vector", [vector])

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	
	if connections["__input"].is_empty():
		invoke_output("vector", [vector])
