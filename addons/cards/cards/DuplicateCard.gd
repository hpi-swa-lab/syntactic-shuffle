@tool
extends Card
class_name DuplicateCard

func v():
	title("Duplicate")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF1JREFUOI3VksEOwCAIQ9tl///L3UkPuKIJepAjwUdLpSRU6im9BvACAMlUhiSmgGxoBi9bGABtY9zslAyAZiVachatgtW+VbDa7ynMrk1SfxBu/4kxBZfKOQX3AT4hky4lOFP8dwAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["node", t("Node")], ["trigger", trg()]], [["out", t("Node")]], func (card, out, node):
		var dupl = node.duplicate(DUPLICATE_SIGNALS | DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_USE_INSTANTIATION)
		out.call(dupl)
, ["node"])
	code_card.position = Vector2(841.9999, 540.9999)
	
	var in_card = InCard.data(t("Node"))
	in_card.position = Vector2(389.888, 431.973)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1311.698, 489.5242)
	
	var in_card_2 = InCard.trigger()
	in_card_2.position = Vector2(507.754, 1005.65)
	
	code_card.c(out_card)
	in_card.c_named("node", code_card)
	in_card_2.c_named("trigger", code_card)
