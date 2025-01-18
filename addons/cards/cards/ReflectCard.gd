@tool
extends Card
class_name ReflectCard

func s():
	title("Reflect")
	description("Reflect a vector.")
	icon("reflect.png")
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create(["Vector2"], func (card):
		var v = card.get_named_input("vector")
		var n = card.get_named_input("normal")
		# FIXME n != Vector.ZERO
		card.output([v.reflect(n)]))
	code_card.c(out_card)
	
	var remember_vector_card = RememberCard.new()
	remember_vector_card.c(code_card)
	var remember_normal_card = RememberCard.new()
	remember_normal_card.c(code_card)
	
	var vector_card = NamedInCard.named_data("vector", "Vector2")
	vector_card.c(remember_vector_card)
	var normal_card = NamedInCard.named_data("normal", "Vector2")
	normal_card.c(remember_normal_card)
