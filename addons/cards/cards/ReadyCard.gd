@tool
#thumb("PlayStart")
extends Card

var input = Slot.ObjectInputSlot.new()
var output = Slot.OutputSlot.new(1)

func _ready() -> void:
	super._ready()
	input.on_connect = func(n): n.ready.connect(on_ready.bind(n))
	input.on_disconnect = func(n): n.ready.disconnect(on_ready)
	
	setup("Ready", "Emits a signal when this card first appears.", Card.Type.Trigger, [input, output])

func on_ready(node):
	output.invoke(self, [node])
