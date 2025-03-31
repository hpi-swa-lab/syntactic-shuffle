@tool
extends Card
class_name FormatStringCard

func v():
	title("Format String")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGBJREFUOI3NkUsKQCEMAyfe/855q4I/+gq6MBuhpEMaZZsTtaPtKwBJBog3VJ1vE0iybQHY1gwZEvTGSuTZ/0CJ86C/P5T1MAB2y3+QVjFl8OWEHSRL9uAvXAH0PWT3A3wlvUUhpBK6uwAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var cell_card = CellCard.create("string", "String", "")
	cell_card.position = Vector2(756.4291, 246.2907)
	
	var code_card = CodeCard.create([["string", t("String")], ["values", t("Dictionary")]], [["out", t("String")]], func (card, out, string, values):
		out.call(string.format(values))
, [])
	code_card.position = Vector2(705.3474, 790.7557)
	
	var in_card = InCard.data(t("Dictionary"))
	in_card.position = Vector2(100.0, 400.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1145.347, 790.7557)
	
	cell_card.c_named("string", code_card)
	code_card.c(out_card)
	in_card.c_named("values", code_card)
