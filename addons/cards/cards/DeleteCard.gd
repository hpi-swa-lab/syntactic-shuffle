@tool
extends Card

func _ready() -> void:
	super._ready()
	setup("Delete",
		"Delete a node.",
		"delete.png",
		CardVisual.Type.Effect,
		[ObjectInputSlot.new(), InputSlot.new({"delete_input": [], "delete_arg": ["Node"]})])

func delete_input():
	var input = get_object_input()
	if input: delete_arg(input)

func delete_arg(obj):
	obj.queue_free()


#func _ready2():
	#setup("Delete",
		#"Delete a node.",
		#"delete.png",
		#CardVisual.Type.Effect,
		#[Operation.new([["Node"]], func(n): n.queue_free())])
# --> [ObjectInputSlot.new(), InputSlot.new({"trigger": [], "delete_arg": ["Node"]})])


class Operation:
	func _init(signatures: Array[Array], _do: Callable, output_signature: Array[String]):
		pass

class Fact:
	enum Mode {
		ALWAYS_UNLESS_TRIGGER,
		ALWAYS,
		TRIGGER
	}
	func _init(signature: Array[String], mode = Mode.ALWAYS_UNLESS_TRIGGER):
		pass

class PollingSignal:
	func _init(input_signature: Array[String], output_signature: Array[String], poll: Callable, physics = false):
		pass

class SubscriptionSignal:
	func _init(input_signature: Array[String], output_signature: Array[String], connect: Callable, disconnect: Callable):
		pass
