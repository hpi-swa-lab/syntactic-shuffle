extends CanvasLayer

var categories = {
	"Input": [
		"AxisControlsCard",
	],
	"Primitives": [
		"Vector2Card",
		"NumberCard",
	],
	"Time": [
		"ClockCard",
	],
	"Actions": [
		"DeleteCard",
	],
	"Movement": [
		"CollisionCard",
		"MoveCard",
	],
	"Math": [
		"IncrementCard",
		"ReflectCard",
		"PlusCard"
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
