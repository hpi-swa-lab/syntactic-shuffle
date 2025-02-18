@tool
extends Card
class_name IfCard

func v():
	title("If")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF5JREFUOI3VksEOwDAIQqH//8/s1MYQF+cSD+XkhRcFKQkAQFKS6HOltQc3k1QL4IYI/ASIiqbqlBQQTdUG3CH+VbrBGCA7pwXI6n3NoArv1NwN0b+0nYH/xWU1jgAeiH49EcWufDwAAAAASUVORK5CYII=")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["data", any("T")], ["trigger", trg()]], [["out", any("T")]], func (card, out, data):
		out.call(data)
, ["data"])
	code_card.position = Vector2(1150.542, 610.6498)
	
	var remember_card = RememberCard.new()
	remember_card.position = Vector2(676.7786, 854.1011)
	
	var in_card = InCard.trigger()
	in_card.position = Vector2(717.3432, 330.6547)
	
	var in_card_2 = InCard.data(any("T"))
	in_card_2.position = Vector2(100.0, 800.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1563.421, 623.2584)
	
	code_card.c(out_card)
	remember_card.c_named("data", code_card)
	in_card.c_named("trigger", code_card)
	in_card_2.c(remember_card)
