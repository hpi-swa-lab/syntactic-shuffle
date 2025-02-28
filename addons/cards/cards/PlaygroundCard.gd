@tool
extends Card
class_name PlaygroundCard

func v():
	title("Playground")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAG9JREFUOI2tkksSwCAIQ0nH+185XTlDI79Om6XI0wRA0joBoJkZSWjt6hoBcDdu0BjgX80gUAt6Qb+tdpYWI58K9I+0FjodgCioMaBKO9PSg7eQYwqPooNk4f4fYqRqtClgmkEIONa1gH3eg3IKE92fs0Ef4G+WPgAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var card = Card.new(func ():
		pass,
	func (c):
		c.title("Test")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAHJJREFUOI2lkkESwCAIA0mn//9yeqJjhSBWbgqJCwiSdhLXkdrM7vEAoI1DEsFgTCjTkFczcOEsCHVu8AffLGmhKi4J3gtBoozCGrNCkgDAzFwSuGirBTX5aiOfIa5ey2LrK2czaBlUZG0CN5kp5FfuxgMmLlIH/KqBfwAAAABJRU5ErkJggg=="))
	card.position = Vector2(-882.6387, -260.6037)
	
