@tool
#thumb("noise.png")
extends Card

var elapsed_time = 0.0
var noise = FastNoiseLite.new()
var speed = SpinBox.new()

func _ready() -> void:
	super._ready()
	speed.value = 1
	elapsed_time = randf() * 100
	
	setup("Noise",
		"Trigger a singal every frame with a continuously changing value.",
		Card.Type.Effect,
		[OutputSlot.create(1)],
		speed)

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint():
		return
	
	invoke_output([noise.get_noise_1d(elapsed_time)])
	elapsed_time += delta * speed.value
