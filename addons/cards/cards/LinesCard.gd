@tool
extends Card
class_name LinesCard

func v():
	title("Lines")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAADZJREFUOI1j/P//PwMlgIki3dQwgAWbICMjI15//f//nxGudsDDAO4FQs5GBqNeQAWjXqCCAQDg8B8VKSsPPAAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["string", t("String")]], [["out", it(t("String"))]], func (card, out, string):
		out.call(string.split("\n"))
, [])
	code_card.position = Vector2(675.5537, 402.4054)
	var named_in_card = NamedInCard.named_data("string", t("String"))
	named_in_card.position = Vector2(200.0, 400.0)
	var out_card = OutCard.new()
	out_card.position = Vector2(1190.92, 400.0026)
	
	code_card.c(out_card)
	named_in_card.c_named("string", code_card)
