@tool
extends Card
class_name NodesInGroupCard

func v():
	title("Nodes In Group")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGNJREFUOI3FkzEKwEAIBJ3g/7+8qYSQ3OnCFbGyWIdREElxUtfRdERkNcBSRRIWYBXeQZ81rgCoA42AaQX7iDuTfIc6kxZQqoA67YJUJruQY/IBuCZbgGsyAlyT1sAx4fdvvAHwWDozIueRPwAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var cell_card = CellCard.create("group_name", "String", "")
	cell_card.position = Vector2(808.8936, 225.9817)
	var code_card = CodeCard.create([["group_name", t("String")], ["[trigger]", trg()]], {"out": it(t("Node"))}, func (card, group_name):
		card.output("out", [card.card_parent_in_world().get_tree().get_nodes_in_group(group_name)])
, ["group_name"])
	code_card.position = Vector2(876.1069, 856.0184)
	var out_card = OutCard.new()
	out_card.position = Vector2(1352.92, 774.4359)
	var in_card = InCard.trigger()
	in_card.position = Vector2(370.3734, 912.1141)
	
	cell_card.c_named("group_name", code_card)
	code_card.c(out_card)
	in_card.c_named("[trigger]", code_card)
