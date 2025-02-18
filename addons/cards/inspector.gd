extends Panel

var card: InspectCard

const LOADING_MARKER = "--loading--"

func attach_cards(card: Card, size: Vector2):
	self.card = card
	card.reported_object.connect(report_object)
	card.clear.connect(clear)
	
	if card.last_object: report_object(card.last_object)
	else:
		var r = card.get_inputs()[0].get_remembered()
		if r: report_object(r.get_remembered_value()[0])
	
	await get_tree().process_frame
	self.size = Vector2(600, 400)

func detach_cards():
	pass

func clear():
	%Tree.clear()

func report_object(object):
	%Tree.clear()
	
	if object is String:
		%Tree.visible = false
		%Text.visible = true
		if %Text.text != object: %Text.text = object
	else:
		%Tree.visible = true
		%Text.visible = false
		_report_object(object, "root", null, true)

func _report_object(object, field_name, parent, expand):
	var item: TreeItem = %Tree.create_item(parent)
	item.set_text(0, field_name)
	item.set_text(1, str(object))
	item.set_expand_right(0, false)
	item.set_expand_right(1, true)
	item.collapsed = not expand
	
	_report_children(object, item, expand)

func _report_children(object, parent, expand):
	if object is Object or object is Dictionary:
		var l = object.keys() if object is Dictionary else object.get_property_list()
		if expand:
			for prop in l:
				var n = prop if prop is String else prop["name"]
				_report_object(object.get(n), n, parent, false)
		else:
			var loading = %Tree.create_item(parent)
			loading.set_metadata(0, object)
			loading.set_text(0, LOADING_MARKER)

var resizing = false
func _on_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		resizing = event.is_pressed()
	if event is InputEventMouseMotion and resizing:
		size += event.relative

func _on_tree_item_collapsed(item: TreeItem) -> void:
	if not item.collapsed and item.get_child_count() == 1 and item.get_child(0).get_text(0) == LOADING_MARKER:
		await get_tree().process_frame
		var object = item.get_child(0).get_metadata(0)
		item.remove_child(item.get_child(0))
		_report_children(object, item, true)

func _on_close_button_pressed() -> void:
	card.visual.expanded = false
