@tool
extends Card
class_name SignalCard

@export var signal_name: String
@export var type: String

var sub

func s():
	title("Signal")
	description("Connect to a singal and trigger when it emits.")
	icon("signal.png")
	
	var out_card = OutCard.data()
	
	var connect_card = CodeCard.create([["obj", cmd("connect", t("Object"))]], {"trigger": trg()}, func (card, obj):
		sub = func (): card.output("trigger", [])
		print(sub)
		obj.connect(signal_name, sub))
	connect_card.c(out_card)
	
	var disconnect_card = CodeCard.create([["obj", cmd("disconnect", t("Object"))]], {}, func (card, obj):
		if sub: obj.disconnect(signal_name, sub)
		sub = null)
	
	var in_object = SubscribeInCard.create(t("Object"))
	in_object.c_named("obj", connect_card)
	#in_object.c_named("obj", disconnect_card)
