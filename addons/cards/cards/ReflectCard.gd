@tool
extends Card
class_name ReflectCard

func v():
	title("Reflect")
	description("Reflect a vector.")
	icon(preload("res://addons/cards/icons/reflect.png"))

func s():
	var out_card = OutCard.data()
	
	var code_card = CodeCard.create([["vector", t("Vector2")], ["normal", t("Vector2")]], [["out", t("Vector2")]], func(card, out, v, n):
		# FIXME n != Vector.ZERO
		out.call(v.reflect(n)))
	code_card.c(out_card)
	
	var remember_vector_card = RememberCard.new()
	remember_vector_card.c_named("vector", code_card)
	var remember_normal_card = RememberCard.new()
	remember_normal_card.c_named("normal", code_card)
	
	var vector_card = NamedInCard.new("vector", t("Vector2"))
	vector_card.c(remember_vector_card)
	var normal_card = NamedInCard.new("normal", t("Vector2"))
	normal_card.c(remember_normal_card)
