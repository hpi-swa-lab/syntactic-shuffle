@tool
#thumb("noise.png")
extends Card

@export var default_speed: float = 1
@export var default_factor: float = 0.03

var elapsed_time = 0.0
var noise = FastNoiseLite.new()
var speed = SpinBox.new()
var factor = SpinBox.new()
var vbox = VBoxContainer.new()

func _ready() -> void:
	super._ready()
	speed.value = 1
	elapsed_time = randf() * 100
	
	speed.step = 0.1
	factor.step = 0.01
	speed.value = default_speed
	factor.value = default_factor
	vbox.add_child(speed)
	vbox.add_child(factor)
	
	setup("Noise",
		"Trigger a singal every frame with a continuously changing value.",
		Card.Type.Effect,
		[OutputSlot.create(1)],
		vbox)

func _process(delta: float) -> void:
	super._process(delta)
	if Engine.is_editor_hint():
		return
	
	invoke_output([noise.get_noise_1d(elapsed_time) * factor.value])
	elapsed_time += delta * speed.value
