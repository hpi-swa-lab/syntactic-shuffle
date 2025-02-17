extends Node2D

const PROGRAM_FILE = "res://addons/cards/cards/MoveCard.gd"

var open_cards := [] as Array[Card]

func _ready() -> void:
	load_cards(PROGRAM_FILE)

func save_cards(path = PROGRAM_FILE):
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string("@tool\nextends Card\nfunc s():\n" + Card.serialize_card_construction(get_parent().get_cards()))

func load_cards(path = PROGRAM_FILE):
	if FileAccess.file_exists(path):
		var card = load(path).new()
		open_toplevel_card(card)

func center_camera():
	var c = %Editor.card.cards
	if c.is_empty():
		%CardEditor.position = Vector2.ZERO
	else:
		%CardEditor.position = c.reduce(func (sum, current): return sum + current.global_position, Vector2.ZERO) / c.size()

func open_toplevel_card(card: Card, open = true):
	card.visual_setup()
	card.cards_parent.card_scale = 1.0
	open_cards.push_back(card)
	%ToplevelCardsList.add_tab(card.card_name)
	
	if open:
		%ToplevelCardsList.current_tab = open_cards.size() - 1

func _on_toplevel_cards_list_tab_changed(tab: int) -> void:
	if tab < 0: return
	
	if %ToplevelContainer.get_child_count() > 0:
		%ToplevelContainer.remove_child(%ToplevelContainer.get_child(0))
	%ToplevelContainer.add_child(open_cards[tab].cards_parent)
	%Editor.attach_cards(open_cards[tab], Vector2.ZERO, true)
	center_camera()

func _on_toplevel_cards_list_tab_close_pressed(tab: int) -> void:
	open_cards[tab].queue_free()
	open_cards.remove_at(tab)
	%ToplevelCardsList.remove_tab(tab)

func _on_add_button_pressed() -> void:
	open_toplevel_card(BlankCard.new())
