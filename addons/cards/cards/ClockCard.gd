@tool
extends Card
class_name ClockCard

func v():
	title("Clock")
	description("Trigger a signal after a specified time.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIlJREFUOI2lk70ZwCAIRI8sksb9F7LJJpcmUUD8S6gU5HHAJ/DTpOPnao4HEADImi8izV3nHjqZJEjqR7hSamAPkB6gSaH2yH/UmK08MtUWjYJe5ZGSsIUdezUXpJ+4HuKZc/E3gJ58v0Yfm7Ywm4sB7GyhnG2xtS0oiIQtmAqdc6QA+PAXfv/GG1ZqSDTYmH7EAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var number_card = NumberCard.new()
	number_card.position = Vector2(846.7021, 1355.779)
	number_card.cards[1].data = 0.75000000000012
	var code_card = CodeCard.create([["elapsed", t("float")], ["delta", t("float")], ["seconds", t("float")]], [["out", trg()], ["out_elapsed", t("float")]], func(card, out, out_elapsed, elapsed, delta, seconds):
		elapsed += delta
		if elapsed >= seconds:
			elapsed -= seconds
			out.call(null)
		out_elapsed.call(elapsed)
, ["elapsed", "seconds"])
	code_card.position = Vector2(636.7162, 729.7614)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(123.8394, 652.9629)
	var out_card = OutCard.new()
	out_card.position = Vector2(1645.949, 662.6255)
	var store_card = StoreCard.new()
	store_card.position = Vector2(423.3535, 1365.83)
	var filter_signatures_card = FilterSignaturesCard.new(trg())
	filter_signatures_card.position = Vector2(1235.493, 667.9688)
	var cell_card = CellCard.create("seconds", "float", 1.0)
	cell_card.position = Vector2(690.3109, 108.1368)
	
	number_card.c_named("elapsed", code_card)
	code_card.c(store_card)
	code_card.c(filter_signatures_card)
	physics_process_card.c_named("delta", code_card)
	store_card.c(number_card)
	filter_signatures_card.c(out_card)
	cell_card.c_named("seconds", code_card)
