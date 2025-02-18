@tool
extends Card
class_name SplitCard

func v():
	title("Split")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAD5JREFUOI3dkrENACAMwzD//2xWJjoEBCJLl9aKmqC2RD263gYAnGeleT92wCdPfBsAuIr3vAOVCFC1836RBvqAEyG3ff3MAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["string", t("String")], ["separator", t("String")]], [["out", it(t("String"))]], func (card, out, string, separator):
		out.call(string.split(separator))
, ["separator"])
	code_card.position = Vector2(706.5573, 570.9343)
	
	var cell_card = CellCard.create("separator", "String", "")
	cell_card.position = Vector2(200.0, 400.0)
	
	var in_card = InCard.data(t("String"))
	in_card.position = Vector2(200.0, 800.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1293.784, 613.569)
	
	code_card.c(out_card)
	cell_card.c_named("separator", code_card)
	in_card.c_named("string", code_card)
