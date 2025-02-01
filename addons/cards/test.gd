@tool
extends CardBoundary

class ManualTriggerCard extends Card:
	var type: Signature
	var out_card: OutCard
	
	func _init(type: Signature):
		super._init()
		self.type = type
	
	func v():
		title("Manual Trigger")
		description("For testing purposes.")
	
	func s():
		out_card = OutCard.data()
	
	func trigger(data):
		out_card.invoke([data], type)

@export_tool_button("Run") var _run = run
func run():
	for method in get_method_list():
		if method["name"].begins_with("test_"):
			print(method["name"])
			run_cards_test(Callable(self, method["name"]))
	print("Success!")
	get_tree().quit()

func assert_eq(a, b):
	if a != b:
		var msg = "Was {0} but expected {1}".format([a, b])
		print(msg)
		assert(false, msg)

func _ready():
	if not Engine.is_editor_hint(): run()

func run_cards_test(test):
	var card = Card.new()
	Card.push_active_card_list(card)
	if test.get_argument_count() > 0:
		test.call(func ():
			# for c in card.cards: c.setup(null)
			Card.pop_active_card_list())
	else:
		test.call()

func test_named_addition_and_store(ready):
	var store = NumberCard.new()
	
	var plus = PlusCard.new()
	plus.c(store)
	var a = NumberCard.new()
	a.number = 5.0
	a.c_named("left", plus)
	var b = NumberCard.new()
	b.number = 15.0
	b.c_named("right", plus)
	var a_trigger = ManualTriggerCard.new(Signature.TriggerSignature.new())
	a_trigger.c(a)
	var b_trigger = ManualTriggerCard.new(Signature.TriggerSignature.new())
	b_trigger.c(b)
	
	ready.call()
	
	a_trigger.trigger([])
	#b_trigger.trigger([])
	assert_eq(store.number, 20.0)

func test_serialize_constructor(ready):
	var c = CollisionCard.new()
	ready.call()
	assert_eq(c.serialize_constructor(), "CollisionCard.new()")

func test_serialize_gdscript(ready):
	var c = TestSerializeCard.new()
	ready.call()
	c.visual_setup()
	assert_eq(c.serialize_gdscript(), load("res://addons/cards/cards/TestSerializeCard.gd").source_code)

func test_simple_named_connect(ready):
	var l = NumberCard.new()
	var r = NumberCard.new()
	var plus = PlusCard.new()
	ready.call()
	l.try_connect(plus)
	l.try_connect(plus)
	assert_eq(plus.get_first_named_incoming_at("left"), l)
	assert(not plus.named_incoming.has("right"))
	r.try_connect(plus)
	assert_eq(plus.get_first_named_incoming_at("right"), r)

func test_simple_outgoing_connect(ready):
	var increment = IncrementCard.new()
	var process = PhysicsProcessCard.new()
	ready.call()
	process.try_connect(increment)
	assert(process.get_outgoing().has(increment))
	assert(increment.get_incoming().has(process))

func test_simple_incoming_connect(ready):
	var increment = IncrementCard.new()
	var process = PhysicsProcessCard.new()
	ready.call()
	increment.try_connect(process)
	assert(process.get_outgoing().has(increment))
	assert(increment.get_incoming().has(process))

func assert_compatible(a, b, invert = false):
	assert((not invert) == a.compatible_with(b), "Expected {0} to{2} be compatible with {1}".format([
		a.get_description(),
		b.get_description(),
		" *not*" if invert else ""
	]))
func assert_not_compatible(a, b): assert_compatible(a, b, true)

func test_signatures():
	assert_compatible(Signature.TypeSignature.new("float"), Signature.TypeSignature.new("float"))
	assert_compatible(
		Signature.StructSignature.new({"position": Signature.TypeSignature.new("Vector2")}, ["queue_free"]),
		Signature.TypeSignature.new("Node2D"))
	assert_not_compatible(
		Signature.StructSignature.new({"position": Signature.TypeSignature.new("Vector2")}, ["queue_free2"]),
		Signature.TypeSignature.new("Node2D"))
	assert_compatible(Signature.TypeSignature.new("float"), Signature.GenericTypeSignature.new())
	assert_compatible(Signature.GenericTypeSignature.new(), Signature.TypeSignature.new("float"))
	assert_not_compatible(
		Signature.CommandSignature.new("increment", null),
		Signature.GenericTypeSignature.new())
	assert_not_compatible(
		Signature.CommandSignature.new("increment", null),
		Signature.CommandSignature.new("increment", Signature.TypeSignature.new("float")))
	assert_compatible(
		Signature.CommandSignature.new("increment", Signature.TypeSignature.new("float")),
		Signature.CommandSignature.new("increment", Signature.GenericTypeSignature.new()))
	assert_compatible(
		Signature.IteratorSignature.new(Signature.TypeSignature.new("float")),
		Signature.TypeSignature.new("float"))
	assert_not_compatible(
		Signature.TypeSignature.new("float"),
		Signature.IteratorSignature.new(Signature.TypeSignature.new("float")))
	assert_compatible(Signature.TypeSignature.new("CharacterBody2D"), Signature.TypeSignature.new("Node2D"))
	assert_not_compatible(Signature.TypeSignature.new("Node2D"), Signature.TypeSignature.new("CharacterBody2D"))
	assert_not_compatible(Signature.TypeSignature.new("float"), Signature.TypeSignature.new("Vector2"))
	assert_compatible(Signature.GroupSignature.new([&"enemy"]), Signature.GroupSignature.new([&"enemy"]))
	
	assert_not_compatible(Signature.TriggerSignature.new(), Signature.CommandSignature.new("cmd", Signature.TriggerSignature.new()))
	assert_compatible(Signature.CommandSignature.new("cmd", Signature.TriggerSignature.new()), Signature.TriggerSignature.new())

func test_extract_code_card_source_code():
	var src = "var code_card = CodeCard.create(
		[[\"velocity\", t(\"Vector2\")], [\"body\", t(\"Node\")], [\"did_accelerate\", t(\"bool\")], [\"trigger\", trg()]],
		{\"out\": t(\"Vector2\"), \"did_accelerate\": t(\"bool\")},
		func (card, velocity, body, did_accelerate):
			if not did_accelerate:
				# )
				velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * get_process_delta_time()))
			card.output(\"out\", [velocity]), [\"body\", \"velocity\", \"did_accelerate\"])
	code_card.c(velocity_card)
	
	var add_card = CodeCard.create(
		[[\"direction\", t(\"Vector2\")], [\"velocity\", t(\"Vector2\")]],
		{\"out\": t(\"Vector2\"), \"did_accelerate\": t(\"bool\")},
		func (card, direction, velocity):
			var v = a
			\")\"
			'\")'
			card.output(\"did_accelerate\", [true])
			card.output(\"out\", [v]), [\"velocity\"])
"
	var srcs = CodeCard._extract_anonymous_functions(src)
	assert_eq(srcs.size(), 2)
	assert_eq(srcs[0], "func (card, velocity, body, did_accelerate):
			if not did_accelerate:
				# )
				velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * get_process_delta_time()))
			card.output(\"out\", [velocity])")
	assert_eq(srcs[1], "func (card, direction, velocity):
			var v = a
			\")\"
			'\")'
			card.output(\"did_accelerate\", [true])
			card.output(\"out\", [v])")
