@tool
extends Card
func s():
	var inspect_card = InspectCard.new()
	inspect_card.position = Vector2(721.7698, 418.2661)
	
	var string_card = StringCard.new()
	string_card.position = Vector2(621.5417, 425.5394)
	string_card.get_cell("string").data = "tasd

dasdasd
asd 
asd
asdasd"
	
	var clock_card = ClockCard.new()
	clock_card.position = Vector2(467.8345, 477.8476)
	clock_card.get_cell("seconds").data = 1.0
	
	string_card.c(inspect_card)
