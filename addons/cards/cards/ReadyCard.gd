@tool
#thumb("PlayStart.svg")
extends Card

func _ready() -> void:
	super._ready()
	
	setup("Ready", "Emits a signal when this card first appears.", Card.Type.Trigger, [ObjectInputSlot.new("cards"), OutputSlot.create(1)])
	get_input_slot().on_connect = func(n): n.ready.connect(on_ready.bind(n))
	get_input_slot().on_disconnect = func(n): n.ready.disconnect(on_ready)

func on_ready(node):
	get_output_slot().invoke(self, [node])
