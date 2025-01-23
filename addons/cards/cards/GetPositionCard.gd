@tool
extends Card
class_name GetPositionCard

func s():
	title("Position")
	description("Get position of an object.")
	icon(preload("res://addons/cards/icons/location.png"))
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["trigger", trg()], ["object", t("RigidBody2D")]], {"out": t("Vector2")}, func (card, object):
		card.output("out", [object.position]))
	code_card.c(out_card)
	
	var object_card = InCard.data(t("RigidBody2D"))
	object_card.c_named("object", code_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c_named("trigger", code_card)
