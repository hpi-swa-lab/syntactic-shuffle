@tool
extends Card
class_name SpawnCard

func v():
	title("Spawn")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFNJREFUOI3VksEKgFAQAjX2/395ukbsPqRHRHMWUdGAdihJst26AI4MOvFkeudIRN8b2GaqVFfRkwQlZWtPbG/g7khpHcDvJJgSdVv95Egrog1WnGASIh1+lM11AAAAAElFTkSuQmCC")
	container_size(Vector2(1507.083, 1357.673))

func s():
	var code_card = CodeCard.create([["node", t("Node")]], [["out", t("Node")]], func (card, out, node):
		card.card_parent_in_world().cards_parent.add_child(node)
		node.set_meta("cards_spawned", true)
		out.call(node)
, [])
	code_card.position = Vector2(929.202, 535.8705)
	
	var in_card = InCard.data(t("Node"))
	in_card.position = Vector2(225.2629, 525.7653)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1282.0, 541.0)
	
	var duplicate_card = DuplicateCard.new()
	duplicate_card.position = Vector2(522.6016, 707.1583)
	
	var in_card_2 = InCard.trigger()
	in_card_2.position = Vector2(196.59, 1009.801)
	
	var tree = load("res://game/tree.tscn").instantiate()
	tree.position = Vector2(0.0, 0.0)
	tree.name = "tree"
	scene_object(tree)
	
	code_card.c(out_card)
	in_card.c(duplicate_card)
	duplicate_card.c_named("node", code_card)
	in_card_2.c(duplicate_card)
