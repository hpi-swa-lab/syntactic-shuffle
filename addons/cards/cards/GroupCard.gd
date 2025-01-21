@tool
extends Card
class_name GroupCard

@export var group_name = ""

func s():
	title("Group")
	description("All elements in a group.")
	icon("group.png")
	
	var out_card = OutCard.remember()
	
	var code_card = CodeCard.create({"trigger": ""}, ["CharacterBody2D"], func (card, args):
		card.output([get_tree().get_nodes_in_group(group_name)[0]]))
	code_card.c(out_card)
	
	var in_card = InCard.trigger()
	in_card.c_named("trigger", code_card)
