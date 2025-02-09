@tool
extends LineEdit

var node

signal item_selected(object)
var list: Array = []

var _gui_input_keycode

func _gui_input(event):
	if event is InputEventKey and event.pressed:
		_gui_input_keycode = event.keycode
		match event.keycode:
			KEY_DOWN: move_focus(1)
			KEY_UP: move_focus(-1)
			KEY_ENTER, KEY_KP_ENTER: accept_selected()

func accept_selected():
	var index = get_focused_index()
	if index >= 0 and %list.visible:
		selected(index)
		await get_tree().process_frame
		release_focus()

func get_focused_index():
	var l = %list.get_selected_items()
	return l[0] if not l.is_empty() else -1

func start_focus():
	grab_focus()
	select_all()
	build_list(text)

func selected(index: int):
	%list.visible = false
	text = %list.get_item_text(index)
	item_selected.emit(%list.get_item_metadata(index))
	text = ""
	build_list("")

func move_focus(dir: int):
	if %list.item_count == 0: return
	var current = get_focused_index() + dir
	while current < %list.item_count and current >= 0 and not %list.is_item_selectable(current):
		current += dir
	%list.select(clamp(current, 0, %list.item_count - 1))
	%list.ensure_current_is_visible()

func _ready():
	text_changed.connect(build_list)
	focus_exited.connect(func ():
		await get_tree().process_frame
		%list.visible = false)
	focus_entered.connect(func ():
		await get_tree().process_frame
		if text.is_empty(): build_list(""))

func build_list(filter: String):
	%list.clear()
	%list.visible = true
	
	for s in list:
		if fuzzy_match(s["name"], filter):
			var index = %list.add_item(s["name"])
			%list.set_item_metadata(index, s)
	
	if get_focused_index() == -1:
		move_focus(1)
	
	# we always want to be underneath the text input, so wait for it to layout
	await get_tree().process_frame
	%list.global_position = global_position + Vector2(0, get_rect().size.y)

func fuzzy_match(name: String, search: String):
	if search.length() == 0:
		return true
	if name.length() == 0:
		return false
	var _name = name.to_lower()
	var _search = search.to_lower()
	if _name[0] != _search[0]:
		return false
	var name_index = 0
	var search_index = 0
	while true:
		if _search[search_index] == _name[name_index]:
			search_index += 1
		name_index += 1
		if search_index == _search.length():
			return true
		if name_index == _name.length():
			return false
	assert(false, "not reached")

func _on_list_pressed(index):
	if %list.is_item_selectable(index):
		selected(index)
