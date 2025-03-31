@tool
extends Card
class_name WrapCommandCard

func v():
	title("WrapCommand")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF5JREFUOI2tk0sSwDAIQqH3vzNZ2ekkmgmxruX5Q0pCJ56W+lcASZHczpPlvABJjKSrDm4hyw5cSLpEB1Je4RRSAkIYIAtwKgYAzlZ2xEsHmfhrnq2R3MrlCG60n2kAh2Q5Jdz7nCgAAAAASUVORK5CYII=")
	container_size(Vector2(1584.724, 1130.874))

func s():
	var cell_card = CellCard.create("command", "String", "")
	cell_card.position = Vector2(931.9357, 228.1784)
	
	var code_card = CodeCard.create([["command", cmd("data_edited", t("String"))]], [], func (card, command):
		for c in card.parent.cards:
			if c is CodeCard and c != card:
				c.get_output("out").override_signature([cmd(command, any())] as Array[Signature])
, ["names"])
	code_card.position = Vector2(1387.724, 232.9662)
	
	var code_card_2 = CodeCard.create([["data", any("T")]], [["out", cmd("", any("T"))]], func (card, out, data):
		out.call(data)
, ["command"])
	code_card_2.position = Vector2(540.5373, 848.8735)
	
	var in_card = InCard.data(t("Vector2"))
	in_card.position = Vector2(183.9129, 818.3306)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(907.8522, 825.7343)
	
	cell_card.c_named("command", code_card)
	code_card_2.c(out_card)
	in_card.c_named("data", code_card_2)
