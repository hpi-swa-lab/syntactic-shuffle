@tool
extends Card
class_name InspectCard

signal reported_object(object)
signal clear()

var last_object

func allow_edit(): return false

func start_expanded(): return true

func v():
	title("Inspect")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGZJREFUOI3NkksSgCAMQ1vH+185rmRKTIvUjVkCL6QfB2CZ3H26BOD85qxgBtTZ8Ra+E3Cqh0EGZyYywY5+aKAaFcU9ShMoEzlaXqTq9+UiRbgaZdQooQMPgy48JejAZqKJu/q8SBf7TUUZDSfsJAAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["inspect", any("T")]], [["out", any("T")]],
		func(card, out, inspect):
			last_object = inspect
			reported_object.emit(inspect)
			out.call(inspect), [])
	code_card.position = Vector2(842.5, 541.0001)
	
	var in_card = InCard.data(any("T"))
	in_card.position = Vector2(205.1522, 545.3572)
	
	var iterator_code_card = CodeCard.create([["inspect", it(any("T"))]], [["out", it(any("T"))]],
		func(card, out, inspect):
			last_object = inspect
			reported_object.emit(inspect)
			out.call(inspect), [])
	
	var iterator_in_card = InCard.data(it(any("T")))
	iterator_in_card.position = Vector2(205.1522, 545.3572)
	
	in_card.c_named("inspect", code_card)
	iterator_in_card.c_named("inspect", iterator_code_card)

func create_expanded(): return load("res://addons/cards/inspector.tscn").instantiate()

func incoming_disconnected(obj: Card):
	super.incoming_disconnected(obj)
	clear.emit()
