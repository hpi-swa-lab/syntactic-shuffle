@tool
#thumb("pistol.png")
extends Card

func _ready() -> void:
	super._ready()
	setup("Shoot",
		"Shoot a gun!",
		Card.Type.Effect,
		[ObjectInputSlot.create("gun"), InputSlot.create(0)])
	on_invoke_input(invoke)

func invoke():
	var input_gun = get_object_input_slot().get_object(self)
	if input_gun: input_gun.shoot()
