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
		c.title("Actuals")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAABxJREFUOI1j/P//PwMlgIki3aMGjBowasAgMgAAY5oDHbY8NLoAAAAASUVORK5CYII="))
	card.position = Vector2(953.8778, -785.1133)
	
	var card_2 = Card.new(func ():
		pass,
	func (c):
		c.title("Persons")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAABxJREFUOI1j/P//PwMlgIki3aMGjBowasAgMgAAY5oDHbY8NLoAAAAASUVORK5CYII="))
	card_2.position = Vector2(949.5827, -426.1331)
	
	var card_3 = Card.new(func ():
		pass,
	func (c):
		c.title("StartOfWeekCell")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAABxJREFUOI1j/P//PwMlgIki3aMGjBowasAgMgAAY5oDHbY8NLoAAAAASUVORK5CYII="))
	card_3.position = Vector2(241.9071, -674.4226)
	
	var card_4 = Card.new(func ():
		pass,
	func (c):
		c.title("Range")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGFJREFUOI3VU0EKwDAIW8T/fzk7CU6FKfbSnFrRhNQUJJ8NZDV9gkBjAQBJwt/bBFWzJ6vExA5RuQsx1emwCepkOFoEQJ0oW6+3+1nj34tXSDmoVuiJk41plFNO7v8La4IXBkE6J3pTrOgAAAAASUVORK5CYII="))
	card_4.position = Vector2(-56.7569, -403.4678)
	
	var card_5 = Card.new(func ():
		pass,
	func (c):
		c.title("Add Days")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAABxJREFUOI1j/P//PwMlgIki3aMGjBowasAgMgAAY5oDHbY8NLoAAAAASUVORK5CYII="))
	card_5.position = Vector2(-131.7075, -810.615)
	
	var card_6 = Card.new(func ():
		pass,
	func (c):
		c.title("<Button>")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAABxJREFUOI1j/P//PwMlgIki3aMGjBowasAgMgAAY5oDHbY8NLoAAAAASUVORK5CYII="))
	card_6.position = Vector2(-464.6291, -601.2225)
	
	var card_7 = Card.new(func ():
		pass,
	func (c):
		c.title("Create Actual")
		c.description("")
		c.icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGVJREFUOI3dksEOgDAIQ6nh/3/5edqiNZPN3eRI4LU0CIidyogISTcKoCWAL0liBiKJrAbcmcOPSqVykk3F1UYuvCegN97U3HrbyRmbowJUZnAddvWIiRAr4DLgkcXuK38+4UeAE91IPiEeJeRSAAAAAElFTkSuQmCC"))
	card_7.position = Vector2(-619.6619, -108.4256)
	
