@tool
extends Card
class_name StoreCard

func v():
	title("Store")
	description("Write into a data cell.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF5JREFUOI3FU8sOwCAMErP//2V2MmGVznoqJxMeKlWQHA4APgRJON207gv0B0A7iPfOoH3MjKiYt4BTiONsB054HCMAagdq0HXUPdlx/3ZVbAHVSSz0P6T+AGTfuYoXNegxEV2hqTMAAAAASUVORK5CYII=")

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(516.228, 400.0003)

	var code_card = CodeCard.create([["input", any()]], [["out", cmd("store", any())]], func(card, out, input):
		out.call(input), [])

	var in_card = InCard.data(any())
	in_card.position = Vector2(200.0, 400.0)
	
	in_card.c_named("input", code_card)
	code_card.c(out_card)
