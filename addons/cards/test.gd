@tool
extends CardBoundary

class ManualTriggerCard extends Card:
	var type: Array[String]
	var out_card: OutCard
	
	func _init(type: Array[String]):
		super._init()
		self.type = type
	
	func s():
		title("Manual Trigger")
		description("For testing purposes.")
		icon("plus.png")
		out_card = OutCard.data()
	
	func trigger(data):
		out_card.invoke([data], type)

@export_tool_button("Run") var _run = run
func run():
	for method in get_method_list():
		if method["name"].begins_with("test_"):
			print(method["name"])
			run_cards_test(Callable(self, method["name"]))

func assert_eq(a, b):
	if a != b:
		assert(false, "Was {0} but expected {1}".format([a, b]))

func _ready():
	if not Engine.is_editor_hint(): run()

func run_cards_test(test):
	var cards = Node2D.new()
	Card.push_active_card_list(cards)
	test.call(func ():
		for card in cards.get_children():
			card.setup(null)
		Card.pop_active_card_list())

func test_named_addition_and_store(ready):
	var store = NumberCard.new()
	
	var plus = PlusCard.new()
	plus.c(store)
	var a = NumberCard.new()
	a.c_named("left", plus)
	var b = NumberCard.new()
	b.c_named("right", plus)
	var a_trigger = ManualTriggerCard.new([])
	a_trigger.c(a)
	var b_trigger = ManualTriggerCard.new([])
	b_trigger.c(b)
	
	ready.call()
	
	a.number = 5
	b.number = 15
	a_trigger.trigger([])
	b_trigger.trigger([])
	assert_eq(store.number, 20.0)

func test_simple_named_connect(ready):
	var l = NumberCard.new()
	var r = NumberCard.new()
	var plus = PlusCard.new()
	ready.call()
	l.try_connect(plus)
	l.try_connect(plus)
	assert_eq(plus.get_named_incoming_at("left"), l)
	assert(not plus.named_incoming.has("right"))
	r.try_connect(plus)
	assert_eq(plus.get_named_incoming_at("right"), r)

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
