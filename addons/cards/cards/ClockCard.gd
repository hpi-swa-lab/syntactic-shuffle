@tool
extends Card
class_name ClockCard

func v():
	title("Clock")
	description("Trigger a signal after a specified time.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIlJREFUOI2lk70ZwCAIRI8sksb9F7LJJpcmUUD8S6gU5HHAJ/DTpOPnao4HEADImi8izV3nHjqZJEjqR7hSamAPkB6gSaH2yH/UmK08MtUWjYJe5ZGSsIUdezUXpJ+4HuKZc/E3gJ58v0Yfm7Ywm4sB7GyhnG2xtS0oiIQtmAqdc6QA+PAXfv/GG1ZqSDTYmH7EAAAAAElFTkSuQmCC")

func s():
	var number_card = NumberCard.new()
	number_card.position = Vector2(800.981, 973.1671)
	number_card.cards[1].data = 0.40000000000004
	var code_card = CodeCard.create([["elapsed", t("float")], ["delta", t("float")]], [["out", trg()], ["elapsed", t("float")]], func(card, out, out_elapsed, elapsed, delta):
		elapsed += delta
		if elapsed >= 1.0:
			elapsed -= 1.0
			out.call(null)
		out_elapsed.call(elapsed), ["elapsed"])
	code_card.position = Vector2(590.9951, 347.1498)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(111.8076, 263.1322)
	var out_card = OutCard.static_signature(trg(), false)
	out_card.position = Vector2(1256.032, 290.5263)
	var store_card = StoreCard.new()
	store_card.position = Vector2(377.6326, 983.2177)
	
	number_card.c_named("elapsed", code_card)
	code_card.c(store_card)
	code_card.c(out_card)
	physics_process_card.c_named("delta", code_card)
	store_card.c(number_card)
