@tool
extends Card
class_name ClockCard

func v():
	title("Clock")
	description("Trigger a signal after a specified time.")
	icon(preload("res://addons/cards/icons/clock.png"))

func s():
	var out = OutCard.static_signature(trg())
	
	var elapsed_time = NumberCard.new()
	
	var code_card = CodeCard.create([["elapsed", t("float")], ["delta", t("float")]], {"out": trg(), "elapsed": t("float")}, func(card, elapsed, delta):
		elapsed += delta
		if elapsed >= 1.0:
			elapsed -= 1.0
			card.output("out", [])
		card.output("elapsed", [elapsed]), ["elapsed"])
	
	code_card.c(elapsed_time)
	code_card.c(out)
	elapsed_time.c_named("elapsed", code_card)
	
	var process = PhysicsProcessCard.new()
	process.c_named("delta", code_card)
