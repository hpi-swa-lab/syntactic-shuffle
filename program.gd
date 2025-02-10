@tool
extends Card
func s():
	var axis_controls_card = AxisControlsCard.new()
	axis_controls_card.position = Vector2(213.0, 329.0)
	var nodes_in_group_card = NodesInGroupCard.new()
	nodes_in_group_card.position = Vector2(15.0, 302.0)
	nodes_in_group_card.cards[0].data = "enemy"
	var get_property_card = GetPropertyCard.new()
	get_property_card.position = Vector2(106.0, 244.0)
	get_property_card.cards[1].data = "position"
	var move_card = MoveCard.new()
	move_card.position = Vector2(359.5097, 357.0199)
	var regex_card = RegexCard.new()
	regex_card.position = Vector2(541.0, 337.0)
	regex_card.cards[0].data = "^(?<verb>[^ ]+) (?<path>[^ ]+) HTTP\\/1\\.1\\n(?<headers>[\\S\\s]+?)\\n\\n(?<body>[\\S\\s]*)"
	var signal_card = SignalCard.new()
	signal_card.position = Vector2(514.0698, 462.545)
	signal_card.cards[4].data = "visibility_changed"
	signal_card.cards[5].data = null
	var always_card = AlwaysCard.new()
	always_card.position = Vector2(247.4, 473.0616)
	var number_card = NumberCard.new()
	number_card.position = Vector2(334.7411, 463.355)
	number_card.cards[1].data = 0.12916666666667
	
	axis_controls_card.c(move_card)
	nodes_in_group_card.c(get_property_card)
	always_card.c(number_card)
