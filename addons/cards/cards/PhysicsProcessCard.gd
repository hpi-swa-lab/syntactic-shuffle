@tool
extends Card
class_name PhysicsProcessCard

var out_card: OutCard
var delta_out_card: OutCard

func s():
	title("Always")
	description("Invoke in tick.")
	icon(preload("res://addons/cards/icons/always.png"))
	
	out_card = OutCard.static_signature(trg())
	delta_out_card = OutCard.static_signature(t("float"))

func _physics_process(delta: float):
	super._physics_process(delta)
	if Engine.is_editor_hint(): return
	out_card.invoke([], trg())
	delta_out_card.invoke([delta], t("float"))
