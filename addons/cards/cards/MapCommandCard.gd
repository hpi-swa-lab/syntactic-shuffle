@tool
extends Card
class_name MapCommandCard

func v():
	title("MapCommand")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGNJREFUOI29kkkKwEAIBO2Q/3+5ctFARLLoEMHDjFjajQJsEnv1KemkArqrb6PxKwClhBy+sszMsmevNnAfcNh3QIa0AJIA1JIQzWWtc0gXHxxA5NM72iL/P6QsueXBaIPlgAP5NTz+iqleBgAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["command", cmd("*", any("T"))]], [["out", any("T")]], func (card, out, command):
		out.call(command)
, [])
	code_card.position = Vector2(685.9023, 389.2803)
	var in_card = InCard.data(cmd("*", any("T")))
	in_card.position = Vector2(200.0, 400.0)
	var out_card = OutCard.new()
	out_card.position = Vector2(1190.92, 400.0026)
	var cell_card = CellCard.create("to", "String", "")
	cell_card.position = Vector2(1026.598, 1202.347)
	var cell_card_2 = CellCard.create("from", "String", 0.0)
	cell_card_2.position = Vector2(405.8742, 1103.943)
	
	code_card.c(out_card)
	in_card.c_named("command", code_card)
