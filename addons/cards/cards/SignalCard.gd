@tool
extends Card
class_name SignalCard

@export var signal_name: String
@export var type: String

var sub
var connect_card

func v():
	title("Signal")
	description("Connect to a singal and trigger when it emits.")
	icon(preload("res://addons/cards/icons/signal.png"))

func s():
	var out_card = OutCard.data()
	
	connect_card = CodeCard.create([["obj", cmd("connect", t("Object"))]], [["trigger", trg()], ["one_arg", t(type)]], func (card, trigger, one_arg, obj):
		if not signal_name: return
		sub = func (arg): one_arg.call(arg) if type else func (): trigger.call(null)
		obj.connect(signal_name, sub))
	connect_card.c(out_card)
	
	var disconnect_card = CodeCard.create([["obj", cmd("disconnect", t("Object"))]], [], func (card, obj):
		if sub: obj.disconnect(signal_name, sub)
		sub = null)
	
	var in_object = SubscribeInCard.create(t("Object"))
	in_object.c_named("obj", connect_card)
	in_object.c_named("obj", disconnect_card)
