@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Name", "Get a node's name.", "attribute.png", Card.Type.Trigger, [
		ObjectInputSlot.new(),
		InputSlot.new({"array": ["Array"]}),
		OutputSlot.new({"default": ["String"], "array": ["Array"]}),
	], [])

func array(array: Array):
	invoke_output("array", [array.map(func (s): return s.name)])

func _process(delta: float) -> void:
	super._process(delta)
	var obj = get_object_input()
	if obj: invoke_output("default", [obj.name])
