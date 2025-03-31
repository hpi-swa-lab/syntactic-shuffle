@tool
extends Card
class_name RandomAxisCard

func v():
	title("RandomAxis")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGVJREFUOI3VkzEOwDAIA3H//+frhORGQCplab0lgsMgEBAnuo6yvw+QtB1QC8jkHaQESAJQRASgCfIAZGAmp9Z3CfCqnSonAto+O/teSLmJlYP1r4zxVfYArzy1pukWXs3l/8d0A522SQ/HZhJkAAAAAElFTkSuQmCC")
	container_size(Vector2(2082.583, 901.7018))

func s():
	var always_card = AlwaysCard.new()
	always_card.position = Vector2(676.1467, 619.7018)
	
	var code_card = CodeCard.create([["float", trg()]], [["out", t("Vector2")]], func (card, out):
		out.call(Vector2(randf_range(-1, 1), randf_range(-1, 1))), [])
	code_card.position = Vector2(1174.853, 542.2979)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1885.583, 248.6192)
	
	var wrap_command_card = WrapCommandCard.new()
	wrap_command_card.position = Vector2(1539.43, 411.1213)
	wrap_command_card.get_cell("command").data = "direction"
	
	always_card.c_named("float", code_card)
	code_card.c(wrap_command_card)
	wrap_command_card.c(out_card)
