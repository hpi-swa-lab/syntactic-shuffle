@tool
extends Card
class_name UnwrapCommandCard

func v():
	title("UnwrapCommand")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAF9JREFUOI3Fk1EKwDAIQ5PR+185+3IEkYIWOj8DeZKglISTWZVI8qNK4g7wHK2/CiApj9YGRBcZ0opQQdodZMioRIdwckixXRKXCyHuDsnNQDNCNrcAlRkARh34/P8LL1V2Nx1HCBDqAAAAAElFTkSuQmCC")
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
	
	code_card.c(out_card)
	in_card.c_named("command", code_card)
