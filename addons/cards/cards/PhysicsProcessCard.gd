@tool
extends Card
class_name PhysicsProcessCard

var out_card: OutCard

func s():
	title("Physics Process")
	description("Invoke in every physics tick.")
	icon("code.png")
	
	out_card = OutCard.static_signature([])

func _physics_process(delta: float):
	out_card.invoke([], [])
