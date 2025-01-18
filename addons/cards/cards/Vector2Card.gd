@tool
extends Card

@export var vector: Vector2 = Vector2.ZERO:
	get: return vector
	set(v):
		if vector == v: return
		vector = v
		vector_x.set_value_no_signal(v.x)
		vector_y.set_value_no_signal(v.y)
		editor_sync_prop("vector")

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
	
	setup("2D Vector", "Stores a 2D Vector. Continuously outputs it, unless an input is connected.", "vector.png", CardVisual.Type.Trigger,
		[
			OutputSlot.new({"vector": ["Vector2"]}),
			InputSlot.new({
				"trigger": [],
				"override": ["Vector2"]
			})
		],
		[vector_x, vector_y])

func override(vector: Vector2):
	self.vector = vector
	trigger()

func trigger():
	invoke_output("vector", [vector])

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint(): return
	
	if connections["__input"].is_empty():
		trigger()
