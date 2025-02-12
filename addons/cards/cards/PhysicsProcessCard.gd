@tool
extends Card
class_name PhysicsProcessCard

var out_card: OutCard
var delta_out_card: OutCard

func v():
	title("Physics Process")
	description("Invoke in every physics tick.")
	icon(preload("res://addons/cards/icons/always.png"))

func can_edit(): return false

func s():
	out_card = StaticOutCard.new("trigger", trg())
	delta_out_card = StaticOutCard.new("delta", t("float"))

func _physics_process(delta: float):
	if Engine.is_editor_hint() or disable: return
	out_card.invoke([], trg())
	delta_out_card.invoke([delta], t("float"))
