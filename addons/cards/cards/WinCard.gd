@tool
extends Card
class_name WinCard

func s():
	title("Win")
	description("Trigger to win!")
	icon(preload("res://addons/cards/icons/bool.png"))
	
	var code_card = CodeCard.create([["in", trg()]], {}, func(card):
		confetti.emitting = true)
	
	var in_card = InCard.trigger()
	in_card.c_named("in", code_card)

var confetti: GPUParticles2D

func _ready() -> void:
	super._ready()
	confetti = preload("res://addons/cards/confetti.tscn").instantiate()
	add_child(confetti)
