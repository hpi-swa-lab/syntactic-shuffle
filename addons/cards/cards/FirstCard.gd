@tool
extends Card
class_name FirstCard

func v():
	title("First")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGRJREFUOI3dk0sOwCAIRN803v/K001NLKkWSVedlRgeDH5km11Jsm0BHBV4jNu4YVsxXsEALSb2dUx+giE5wgxOFViNlHYwg+E6gwp4K9BtxlvIqMUObx2jth/SDwuo8hs/dXACUIkyI7YEObwAAAAASUVORK5CYII=")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["iterator", it(any("T"))]], [["out", any("T")]], func (card, out, iterator):
		if not iterator.is_empty():
			out.call(iterator[0])
, [])
	code_card.position = Vector2(698.5455, 398.2183)
	var named_in_card = NamedInCard.named_data("iterator", it(any("T")))
	named_in_card.position = Vector2(200.0, 400.0)
	var out_card = OutCard.new()
	out_card.position = Vector2(1190.92, 400.0026)
	
	code_card.c(out_card)
	named_in_card.c_named("iterator", code_card)
