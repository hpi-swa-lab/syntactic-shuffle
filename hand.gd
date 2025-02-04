extends CanvasLayer

var categories = {
	"Abstraction": [
		CodeCard.new([], {"out": Signature.TypeSignature.new("")}, func(_card): pass, [], "func(_card): card.output(\"out\", [null])"),
		CellCard.new("value", "float", 0.0),
		FilterSignaturesCard.new(Signature.VoidSignature.new()),
		"StoreCard",
		"RememberCard",
		InCard.new(Signature.VoidSignature.new()),
		NamedInCard.new("unnamed", Signature.VoidSignature.new()),
		SubscribeInCard.new(Signature.VoidSignature.new()),
		OutCard.new(),
		BlankCard.new(),
	],
	"Input": [
		"AxisControlsCard",
		"MousePositionCard",
		"ClockCard",
		"PhysicsProcessCard"
	],
	"Data": [
		"SetPropertyCard",
		"GetPropertyCard",
		"Vector2Card",
		"IncrementCard",
		"NumberCard",
		"BoolCard",
		"ToggleCard",
	],
	"Actions": [
		"DeleteCard",
	],
	"Movement": [
		"CollisionCard",
		"MoveCard",
		"LookAtCard",
		"GravityCard"
	],
	"Math": [
		"IncrementCard",
		"ReflectCard",
		"PlusCard",
		"MultiplyCard",
		"MinusCard",
		"DivideCard"
	],
}

func _ready() -> void:
	var column = VBoxContainer.new()
	column.position = Vector2(0, 80)
	add_child(column)
	
	for category in categories:
		var label = Label.new()
		label.text = category
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_child(label)
		column.add_child(margin)
		
		const STACK_SIZE = Vector2(140, 100)
		
		var stack = CardBoundary.new()
		stack.duplicate_on_drag = true
		stack.card_layout = CardBoundary.Layout.COLLAPSED_ROW
		stack.disable_on_enter = true
		stack.card_scale = 0.3
		stack.position = STACK_SIZE / 2 + Vector2(20, 0)
		for card_name in categories[category]:
			var card = load("res://addons/cards/cards/{0}.gd".format([card_name])).new() if card_name is String else card_name
			stack.add_child(card)
		
		var collider = CollisionShape2D.new()
		collider.shape = RectangleShape2D.new()
		collider.shape.size = STACK_SIZE
		stack.add_child(collider)
		
		var stack_wrapper = Control.new()
		stack_wrapper.custom_minimum_size = STACK_SIZE
		stack_wrapper.add_child(stack)
		
		column.add_child(stack_wrapper)
		stack._relayout()
		
		
		column.add_spacer(false)
	
	var t = Trash.new()
	t.position = Vector2(60, categories.size() * 145)
	column.add_child(t)
