@tool
extends Card
class_name ForwardTriggerCard

func v():
	title("ForwardTrigger")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGZJREFUOI29k0sKwDAIRPNy/ztPNw1I/TRBiMs483CUIGl0arbcVwCAgDTntMJIIImqvxWhgiDJNZbBiV+d7bPOCCgzVpDjK3zjHANaE0Q7CAHhtgPzGGaJpSh5d4DdsY8Af9X+TA9HA0oRiNeSRAAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["type", any("T")]], [["out", trg()]], func (card, out, type):
		out.call(null)
, [])
	code_card.position = Vector2(775.2624, 524.5641)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1430.834, 389.5409)
	
	var in_card = InCard.data(any("T"))
	in_card.position = Vector2(334.7047, 561.2778)
	
	code_card.c(out_card)
	in_card.c_named("type", code_card)
