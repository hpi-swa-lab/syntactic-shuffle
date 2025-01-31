extends VBoxContainer

signal on_edit(signature)

var signature = Signature.VoidSignature.new():
	get: return signature
	set(v):
		signature = v
		if is_inside_tree(): _update_visible()

func _ready() -> void:
	_update_visible()

func _update_visible():
	var type = get_type_label(signature)
	for i in range($Subclass.item_count):
		if $Subclass.get_item_text(i) == type:
			$Subclass.selected = i
			break
	
	for child in get_children():
		if child != $Subclass:
			print(child)
			child.queue_free()
	
	if signature is Signature.CommandSignature:
		text_field("command", "Command")
		child_signature("arg", "Command Argument")
	if signature is Signature.TypeSignature:
		text_field("type", "Type Name")
	if signature is Signature.StructSignature:
		pass # TODO
	if signature is Signature.GroupSignature:
		string_array("group_names", "Group Names")
	if signature is Signature.IteratorSignature:
		child_signature("type", "Iterated Type")

func label(label: String):
	var t = Label.new()
	t.text = label
	t.add_theme_font_size_override("font_size", 8)
	t.add_theme_color_override("font_color", Color.BLACK)
	add_child(t)

func text_field(prop_name: String, label: String):
	label(label)
	
	var l = LineEdit.new()
	l.placeholder_text = label
	l.text = signature.get(prop_name)
	l.text_changed.connect(func (t): signature.set(prop_name, l.text))
	add_child(l)

func string_array(prop_name: String, label: String):
	label(label)
	
	var l = LineEdit.new()
	l.placeholder_text = label + " (comma-separated)"
	l.text = ",".join(signature.get(prop_name))
	l.text_changed.connect(func (t): signature.set(prop_name, l.text.split(",")))
	add_child(l)

func child_signature(prop_name: String, label: String):
	label(label)
	
	var l = preload("res://addons/cards/signature/signature_edit.tscn").instantiate()
	l.signature = signature.get(prop_name)
	l.on_edit.connect(func (s): signature.set(prop_name, s))
	add_child(l)

func _selected_name(): return $Subclass.get_item_text($Subclass.selected)

func _on_subclass_selected(index: int) -> void:
	match _selected_name():
		"Trigger": signature = Signature.TriggerSignature.new()
		"Command": signature = Signature.CommandSignature.new("", Signature.VoidSignature.new())
		"Type": signature = Signature.TypeSignature.new("")
		"Struct": signature = Signature.StructSignature.new({}, [])
		"Group": signature = Signature.GroupSignature.new([])
		"Iterator": signature = Signature.IteratorSignature.new(Signature.VoidSignature.new())
		"Void": signature = Signature.VoidSignature.new()
		"Generic": signature = Signature.GenericTypeSignature.new()
	
	on_edit.emit(signature)

func get_type_label(s: Signature):
	if s is Signature.TriggerSignature: return "Trigger"
	if s is Signature.CommandSignature: return "Command"
	if s is Signature.TypeSignature: return "Type"
	if s is Signature.StructSignature: return "Struct"
	if s is Signature.GroupSignature: return "Group"
	if s is Signature.IteratorSignature: return "Iterator"
	if s is Signature.VoidSignature: return "Void"
	if s is Signature.GenericTypeSignature: return "Generic"
	if s is Signature.OutputAnySignature: return "Output Any"
	assert(false, "missing signature type")
