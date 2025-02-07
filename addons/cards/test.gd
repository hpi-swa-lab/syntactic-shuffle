@tool
extends CardBoundary

var execute_only = ""

class ManualTriggerCard extends Card:
	var type: Signature
	var out_card: OutCard
	
	func _init(type: Signature):
		super._init()
		self.type = type
		out_card.has_static_signature = true
		out_card.signature = type
	
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
		if method["name"].begins_with("test_") and (not execute_only or method["name"].contains(execute_only)):
			print(method["name"])
			run_cards_test(Callable(self, method["name"]))
	print("Success!")
	get_tree().quit()

func assert_eq(a, b):
	var equal = a.eq(b) if a is Signature else a == b
	if not equal:
		var msg = "Was " + Signature.data_to_expression(a) + " but expected " + Signature.data_to_expression(b)
		print(msg)
		assert(false, msg)

func _ready():
	if not Engine.is_editor_hint(): run()

func run_cards_test(test):
	if test.get_argument_count() > 0:
		var card = Card.new()
		var was_called = {"was": false}
		Card.push_active_card_list(card)
		test.call(func():
			was_called["was"] = true
			Card.pop_active_card_list()
			card.init_signatures())
		assert(was_called["was"], "ready was not called")
	else:
		test.call()

func test_type_of_cell_card(ready):
	var input = ManualTriggerCard.new(Signature.TypeSignature.new("float"))
	var num = NumberCard.new()
	
	input.c(num)
	ready.call()
	
	input.trigger([1.0])

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
	# The other value should be fetched as remembered
	# b_trigger.trigger([])
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
	
	assert_not_compatible(Signature.GenericTypeSignature.new(), Signature.CommandSignature.new("cmd", Signature.GenericTypeSignature.new()))
	assert_compatible(Signature.CommandSignature.new("cmd", Signature.GenericTypeSignature.new()), Signature.GenericTypeSignature.new())
	
	assert_compatible(Signature.IteratorSignature.new(Signature.TypeSignature.new("Vector2")), Signature.IteratorSignature.new(Signature.GenericTypeSignature.new()))

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

func test_casting_generic_signature(ready):
	var store_card = StoreCard.new()
	var number_card = NumberCard.new()
	number_card.c(store_card)
	ready.call()
	
	var signatures = store_card.output_signatures
	assert_eq(signatures.size(), 1)
	assert_compatible(signatures[0], Signature.TypeSignature.new("float"))
	assert_not_compatible(signatures[0], Signature.TypeSignature.new("Vector2"))

func test_derive_output_types_from_incoming(ready):
	var num = NumberCard.new()
	var vector = Vector2Card.new()
	var c = Card.new(func():
		var in1 = InCard.new(Signature.TypeSignature.new("float"))
		var out1 = OutCard.new()
		in1.c(out1)
		
		var in2 = InCard.new(Signature.TypeSignature.new("Vector2"))
		var out2 = OutCard.new()
		in2.c(out2))
	
	num.c(c)
	ready.call()
	assert_eq(c.output_signatures.size(), 1)
	assert_eq(c.output_signatures[0].get_description(), "float")
	
	c.disconnect_all()
	assert_eq(c.output_signatures.size(), 2)
	
	vector.connect_to(c)
	assert_eq(c.output_signatures.size(), 1)
	assert_eq(c.output_signatures[0].get_description(), "Vector2")
	
	c.disconnect_all()
	num.connect_to(c)
	assert_eq(c.output_signatures.size(), 1)
	assert_eq(c.output_signatures[0].get_description(), "float")

func test_derive_output_types_no_incoming(ready):
	var c = Card.new(func():
		var process = PhysicsProcessCard.new()
		var vec = Vector2Card.new()
		var out = OutCard.new()
		process.c(vec)
		vec.c(out))
	ready.call()
	assert_eq(c.output_signatures.size(), 1)
	assert_eq(c.output_signatures[0].get_description(), "Vector2")

func test_derive_output_types_axis_controls(ready):
	var c = AxisControlsCard.new()
	ready.call()
	assert_eq(c.output_signatures.size(), 1)
	assert_eq(c.output_signatures[0].get_description(), ">direction[Vector2]")

func test_derive_output_types_minus(ready):
	var v1 = Vector2Card.new()
	var v2 = Vector2Card.new()
	var c = MinusCard.new()
	v1.c_named("left_vector", c)
	v2.c_named("right_vector", c)
	ready.call()
	assert_eq(c.output_signatures.size(), 1)
	assert_eq(c.output_signatures[0].get_description(), "Vector2")

func test_cannot_connect_to_concrete_generic(ready):
	var store_card = StoreCard.new()
	var number_card = NumberCard.new()
	var bool_card = BoolCard.new()
	number_card.c(store_card)
	ready.call()
	
	bool_card.try_connect(store_card)
	assert(store_card.get_all_connected().has(number_card))
	assert(not store_card.get_all_connected().has(bool_card))

func test_derive_type_from_code_card(ready):
	var code_card = CodeCard.new([],
		[["out_float", Signature.TypeSignature.new("float")], ["out_vec", Signature.TypeSignature.new("Vector2")]],
		func(card): pass )
	var store_card = StoreCard.new()
	code_card.c(store_card)
	ready.call()
	assert_eq(store_card.output_signatures.size(), 2)

func test_make_concrete_pull_only(ready):
	var vector_card = Vector2Card.new()
	var pull_only_card = PullOnlyCard.new()
	
	vector_card.c(pull_only_card)
	ready.call()
	
	assert_eq(pull_only_card.output_signatures[0].get_description(), "Vector2")

func test_pull_only_in_loop(ready):
	var vector_card = Vector2Card.new()
	var store_card = StoreCard.new()
	var pull_only_card = PullOnlyCard.new()
	
	vector_card.c(pull_only_card)
	pull_only_card.c(store_card)
	ready.call()
	
	store_card.try_connect(vector_card)
	assert(store_card.get_outgoing().has(vector_card))

func test_get_description_with_cycle(ready):
	var vector_card = Vector2Card.new()
	var store_card = StoreCard.new()
	var pull_only_card = PullOnlyCard.new()
	
	vector_card.c(pull_only_card)
	pull_only_card.c(store_card)
	store_card.c(vector_card)
	# test that this does not cause an infinite loop
	ready.call()

func test_type_of_subscribe_in_card(ready):
	var subscribe_card = SubscribeInCard.new(Signature.TypeSignature.new("float"))
	ready.call()
	
	assert_eq(subscribe_card.output_signatures.size(), 3)
	assert_eq(subscribe_card.output_signatures[1].command, "connect")
	assert_eq(subscribe_card.output_signatures[2].command, "disconnect")

func test_group_with_overlapping_outputs_merges(ready):
	var a_minus_card = MinusCard.new()
	var b_minus_card = MinusCard.new()
	var a_r = RememberCard.new()
	var b_r = RememberCard.new()
	var a = NumberCard.new()
	var b = NumberCard.new()
	a.c(a_r)
	b.c(b_r)
	a_r.c(a_minus_card)
	b_r.c(b_minus_card)
	ready.call()
	
	var cam = CardCamera.new()
	cam.add_to_selection(a_r)
	cam.add_to_selection(b_r)
	cam.add_to_selection(a)
	cam.add_to_selection(b)
	
	var container = cam.group_selected()
	assert_eq(container.cards.filter(func(c): return c is OutCard).size(), 1)

func test_group_with_overlapping_inputs_produces_named_inputs(ready):
	var minus_card = MinusCard.new()
	var a_r = RememberCard.new()
	var b_r = RememberCard.new()
	var a = NumberCard.new()
	var b = NumberCard.new()
	a.c(a_r)
	b.c(b_r)
	a_r.c(minus_card)
	b_r.c(minus_card)
	ready.call()
	
	var cam = CardCamera.new()
	cam.add_to_selection(a_r)
	cam.add_to_selection(b_r)
	cam.add_to_selection(minus_card)
	
	var container = cam.group_selected()
	assert_eq(container.cards.filter(func(c): return c is InCard).size(), 2)
	assert_eq(container.cards.filter(func(c): return c is NamedInCard).size(), 2)

func test_dedent():
	assert_eq(CodeEditor.dedent("	a
		b
			c
		d"), "a
	b
		c
	d
")
	assert_eq(CodeEditor.dedent("		if not iterator.is_empty():
			out.call(iterator[0])
"
), "if not iterator.is_empty():
	out.call(iterator[0])
")

func test_initialize_get_property(ready):
	var get_prop = GetPropertyCard.new()
	get_prop.property_name = "position"
	
	var c = CharacterBody2D.new()
	Card.active_card_list.back().cards_parent.add_child(c)
	var object = Card.ensure_card(c)
	object.c(get_prop)
	
	ready.call()
	
	assert_eq(get_prop.output_signatures.size(), 1)
	assert_eq(get_prop.output_signatures[0], Signature.TypeSignature.new("Vector2"))

func test_iterator_invoke(ready):
	var reported = []
	var array_card = Card.new(func():
		OutCard.static_signature(Signature.IteratorSignature.new(Signature.TypeSignature.new("Node"))))
	
	var get_prop = GetPropertyCard.new()
	get_prop.property_name = "position"
	
	var report_card = CodeCard.new([["data", Signature.GenericTypeSignature.new()]], [], func(card, data):
		reported.push_back(data))
	
	array_card.c(get_prop)
	get_prop.c_named("data", report_card)
	ready.call()
	
	assert_eq(get_prop.output_signatures[0], Signature.IteratorSignature.new(Signature.TypeSignature.new("Vector2")))
	
	for c in array_card.get_outputs():
		c.invoke([[CharacterBody2D.new(), CharacterBody2D.new()]], Signature.IteratorSignature.new(Signature.TypeSignature.new("Node")))
	assert_eq(reported, [Vector2.ZERO, Vector2.ZERO])

func test_iterator_aggregate(ready):
	var reported = {"reported": null}
	var array_card = Card.new(func():
		OutCard.static_signature(Signature.IteratorSignature.new(Signature.TypeSignature.new("Node"))))
	
	var get_prop = GetPropertyCard.new()
	get_prop.property_name = "position"
	
	var report_card = CodeCard.new(
		[["data", Signature.IteratorSignature.new(Signature.GenericTypeSignature.new())]],
		[["out", Signature.TypeSignature.new("Vector2")]],
		func(card, out, data): reported["reported"] = data)
	
	array_card.c(get_prop)
	get_prop.c_named("data", report_card)
	ready.call()
	
	assert_eq(report_card.output_signatures[0], Signature.TypeSignature.new("Vector2"))
	
	for c in array_card.get_outputs():
		c.invoke([[CharacterBody2D.new(), CharacterBody2D.new()]], Signature.IteratorSignature.new(Signature.TypeSignature.new("Node")))
	assert_eq(reported["reported"], [Vector2.ZERO, Vector2.ZERO])

func test_iterator_make_concrete():
	var a = Signature.IteratorSignature.new(Signature.TypeSignature.new("Vector2"))
	var b = Signature.IteratorSignature.new(Signature.GenericTypeSignature.new())
	var res = b.make_concrete([a])
	assert_eq(res.size(), 1)
	assert_eq(res[0], a)

func test_iterator_make_concrete_with_cards(ready):
	var array_card = Card.new(func():
		OutCard.static_signature(Signature.IteratorSignature.new(Signature.TypeSignature.new("Vector2"))))
	
	var report_card = CodeCard.new(
		[["data", Signature.IteratorSignature.new(Signature.GenericTypeSignature.new())]],
		[["out", Signature.GenericTypeSignature.new()]],
		func(card, out, data): pass)
	
	array_card.c_named("data", report_card)
	ready.call()
	
	assert_eq(report_card.input_signatures[0], Signature.IteratorSignature.new(Signature.TypeSignature.new("Vector2")))
	assert_eq(report_card.output_signatures[0], Signature.TypeSignature.new("Vector2"))
