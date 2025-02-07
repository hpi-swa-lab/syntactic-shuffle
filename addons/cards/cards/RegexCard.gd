@tool
extends Card
class_name RegexCard

func v():
	title("Regex")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFVJREFUOI3FkkEKACEMA43s/788e1oR0VYJuLlnmoQKKI6q5b4GkLTsGQJG4wykbMTeBGgbEMXuQXaCdIPPBGiWKgSMF4822NXTSEnXlf5/ZXsDO8ELCC4zDVnfW4gAAAAASUVORK5CYII=")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var cell_card = CellCard.create("regex", "String", ".*")
	cell_card.position = Vector2(513.7805, 176.8419)
	var code_card = CodeCard.create([["string", t("String")], ["regex", t("String")]], [["out", t("RegExMatch")]], func (card, out, string, regex):
		var r = RegEx.new()
		r.compile(regex)
		var res = r.search(string)
		if res: out.call(res)
, ["regex"])
	code_card.position = Vector2(711.1526, 654.3732)
	var in_card = InCard.data(t("String"))
	in_card.position = Vector2(205.9927, 650.1636)
	var out_card = OutCard.new()
	out_card.position = Vector2(1228.895, 654.6946)
	
	cell_card.c_named("regex", code_card)
	code_card.c(out_card)
	in_card.c_named("string", code_card)
