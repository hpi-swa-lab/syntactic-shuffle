@tool
extends Card
class_name StringEqualCard

func v():
	title("String Equal")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADtJREFUOI1j/P//PwMlgIki3VQzgJGR8T8yTVcXMFIaiCw4TSbgnf///zMyMIx6gYGBCl4YJEl5QA0AAMvWFhnOfsWcAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var cell_card = CellCard.create("value", "String", "")
	cell_card.position = Vector2(463.4648, 964.6503)
	
	var code_card = CodeCard.create([["string", t("String")], ["compare", t("String")]], [["out", trg()]], func (card, out, string, compare):
		if string == compare: out.call(null)
, ["compare"])
	code_card.position = Vector2(521.5212, 443.7155)
	
	var in_card = InCard.data(t("String"))
	in_card.position = Vector2(100.0, 400.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(961.5212, 443.7155)
	
	cell_card.c_named("compare", code_card)
	code_card.c(out_card)
	in_card.c_named("string", code_card)
