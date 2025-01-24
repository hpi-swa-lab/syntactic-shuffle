@tool
extends Card
class_name GroupCard

@export var group_name = ""

func v():
	title("Group")
	description("All elements in a group.")
	icon(preload("res://addons/cards/icons/group.png"))

func s():
	var out_card = OutCard.remember()
	
	var code_card = CodeCard.create([["trigger", trg()]], {"out": t("Node")}, func (card):
		var elements = get_tree().get_nodes_in_group(group_name)
		if not elements.is_empty():
			card.output("out", [elements[0]]))
	code_card.c(out_card)
	
	var in_card = InCard.trigger()
	in_card.c_named("trigger", code_card)
