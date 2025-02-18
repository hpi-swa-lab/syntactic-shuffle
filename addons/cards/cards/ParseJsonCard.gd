@tool
extends Card
class_name ParseJsonCard

func v():
	title("Parse JSON")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFVJREFUOI3tk0EKwDAIBJ38/8/TSwPBtpKQW6gguKiLK4oaO9a2ug8jAHyLqxzgYwJAlV6YcSb5lKCyJGFszBKWCGZIxnyrFjZl9ymrRvcK55j/F+ICCK9NAxGj3ZsAAAAASUVORK5CYII=")
	container_size(Vector2(1135.335, 831.1046))

func s():
	var code_card = CodeCard.create([["string", t("String")]], [["out", t("")]], func (card, out, string):
		out.call(JSON.parse_string(string))
, [])
	code_card.position = Vector2(533.6737, 400.0007)
	
	var in_card = InCard.data(t("String"))
	in_card.position = Vector2(200.0, 400.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(928.3172, 397.4531)
	
	code_card.c(out_card)
	in_card.c_named("string", code_card)
