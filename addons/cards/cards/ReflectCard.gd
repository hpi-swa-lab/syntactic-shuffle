@tool
extends Card
class_name ReflectCard

func s():
	title("Reflect")
	description("Reflect a vector.")
	icon("reflect.png")
	
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create({"vector": "Vector2", "normal": "Vector2"}, ["Vector2"], func (card, args):
		var v = args["vector"]
		var n = args["normal"]
		# FIXME n != Vector.ZERO
		card.output([v.reflect(n)]))
	code_card.c(out_card)
	
	var remember_vector_card = RememberCard.new()
	remember_vector_card.c_named("vector", code_card)
	var remember_normal_card = RememberCard.new()
	remember_normal_card.c_named("normal", code_card)
	
	var vector_card = NamedInCard.named_data("vector", "Vector2")
	vector_card.c(remember_vector_card)
	var normal_card = NamedInCard.named_data("normal", "Vector2")
	normal_card.c(remember_normal_card)
