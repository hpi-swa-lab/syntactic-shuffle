@tool
extends Card
class_name PullOnlyCard

func v():
	title("Pull Only")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGFJREFUOI3dkMEOwCAMQsv+/5/fTibMudrG27g1AgIC4gRXlSiJ1V02ADREkgAUEaFuBRe3ErjY66QGTvSfH3WyCoPkkV+cYTCvPOPLpLVBmmD5WKiwTZCJtwkqON7gBwY3v749D22wXEcAAAAASUVORK5CYII=")
	container_size(Vector2(2000.0, 1600.0))
	allow_cycles()

func s():
	var in_card = InCard.data(any())
	in_card.position = Vector2(263.7976, 633.5124)
	var out_card = OutCard.remember()
	out_card.position = Vector2(1062.398, 629.3748)
	var code_card = CodeCard.create([["input", any()]], {"out": any()}, func (card, input):
		var sig = [] as Array[Signature]
		card.get_out_signatures(sig)
		for o in card.get_outgoing():
			o.remembered = [input]
			o.remembered_signature = sig[0]
, [])
	code_card.position = Vector2(661.5192, 786.9964)
	
	in_card.c_named("input", code_card)
	code_card.c(out_card)
