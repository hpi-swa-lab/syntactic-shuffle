extends Button

func start():
	var game = get_tree().root.find_child("Game", true, false)
	if game: game.next_level()
