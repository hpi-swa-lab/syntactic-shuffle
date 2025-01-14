extends CanvasLayer

var categories = {
	"Input": [
		"AxisControlsCard",
		"RandomAxisCard",
		"MouseLeftClickCard",
		"MousePositionCard",
		"MouseRightClickCard",
	],
	"Time": [
		"DelayCard",
		"ClockCard",
	],
	"Spawn": [
		"DeleteCard",
	],
	"Primitives": [
		"Vector2Card",
		"NumberCard",
	],
	"Store": [
		"IncrementCard",
		"StoreCard",
		"SetTextCard",
	],
	"Movement": [
		"CollisionCard",
		"MoveCard",
		"TurnByCard",
		"LookAtCard",
	]
}

func _ready() -> void:
	var column = VBoxContainer.new()
	add_child(column)
	
	for category in categories:
		var label = Label.new()
		label.text = category
		column.add_child(label)
		
		const STACK_SIZE = Vector2(270, 160)
		
		var stack = CardBoundary.new()
		stack.card_layout = CardBoundary.Layout.FAN
		stack.disable_on_enter = true
		stack.card_scale = 0.5
		stack.position = STACK_SIZE / 2 + Vector2(50, 0)
		for card_name in categories[category]:
			var card = load("res://addons/cards/cards/{0}.gd".format([card_name])).new()
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
