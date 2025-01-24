@tool
extends Card
class_name MousePositionCard

func v():
	title("Mouse Position")
	description("Continously emits mouse position.")
	icon(preload("res://addons/cards/icons/mouse_position.png"))

func s():
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["trigger", trg()]], {"out": t("Vector2")}, func (card):
		card.output("out", [get_global_mouse_position()]))
	code_card.c(out_card)
	
	var physics_card = PhysicsProcessCard.new()
	physics_card.c_named("trigger", code_card)
