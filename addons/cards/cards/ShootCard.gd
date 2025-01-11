@tool
#thumb("Remove")
extends Card

func _ready() -> void:
	super._ready()
	setup("Shoot",
		"Shoot a gun!",
		Card.Type.Effect,
		[ObjectInputSlot.create("gun"), InputSlot.create(1)])
	on_invoke_input(invoke)

func invoke(obj):
	var input_gun = get_object_input_slot().get_object(self)
	if input_gun: input_gun.shoot()
