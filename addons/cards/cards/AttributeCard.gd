@tool
extends Card

@export var field: String = "":
	get: return field
	set(v):
		if field == v: return
		field = v
		if field_ui.text != v: field_ui.text = v
		if is_inside_tree(): update_info_label(true)
		editor_sync_prop("field")

var field_ui := LineEdit.new()
var info_label := Label.new()

func _init() -> void:
	field_ui.text = field
	field_ui.text_changed.connect(func (v): field = v)
	
	info_label.add_theme_color_override("font_color", Color.BLACK)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD

func _ready() -> void:
	super._ready()
	setup("Attribute", "Get or set an attribute.", "attribute.png", CardVisual.Type.Trigger, [
		ObjectInputSlot.new(),
		OutputSlot.new({"default": ["*"]}),
		InputSlot.new({"set_value": ["*"]}),
	], [field_ui, info_label])
	
	update_info_label(false)

func get_value():
	var obj = get_object_input()
	if obj:
		if field in obj: return obj.get(field)
		if obj.has_meta(field): return obj.get_meta(field)
	return null

func set_value(arg):
	var obj = get_object_input()
	if obj: obj.set(field, arg)

func _process(delta: float) -> void:
	super._process(delta)
	var obj = get_object_input()
	if obj and not Engine.is_editor_hint():
		invoke_output("default", [get_value()])

func connect_slot(my_slot: Slot, them: Node, their_slot: Slot):
	super.connect_slot(my_slot, them, their_slot)
	
	update_info_label(true)

func update_info_label(check_connections: bool):
	var obj = get_object_input()
	if obj:
		if field in obj or obj.has_meta(field):
			var val = get_value()
			var type = find_type(val)
			info_label.text = "Value: {0}\nType: {1}".format([str(val), type])
			update_type(type, check_connections)
		else:
			info_label.text = "Attribute {0} not defined.".format([field])
			update_type("__never", check_connections)
	else:
		info_label.text = "[no object]"
		update_type("__never", check_connections)

func update_type(type: String, check_connections: bool):
	get_slot_by_name("__input").signatures = {"default": [type]} as Dictionary[String, Array]
	get_slot_by_name("__output").signatures = {"set_value": [type]} as Dictionary[String, Array]
	if check_connections:
		get_slot_by_name("__input").check_output_still_valid()

func find_type(val):
	match typeof(val):
		TYPE_ARRAY: return "Array"
		TYPE_FLOAT: return "float"
		TYPE_INT: return "int"
		TYPE_STRING: return "String"
		TYPE_BOOL: return "bool"
		TYPE_VECTOR2: return "Vector2"
		TYPE_STRING_NAME: return "String"
		_: push_error("Missing type {0}".format([typeof(val)]))
