@tool
extends Card

@export var group_name: String = "":
	get: return group_name
	set(v):
		if group_name == v: return
		group_name = v
		if field_ui.text != v: field_ui.text = v
		editor_sync_prop("group_name")

var field_ui := LineEdit.new()
var info_label := Label.new()

func _init() -> void:
	field_ui.text = group_name
	field_ui.text_changed.connect(func (v): group_name = v)
	
	info_label.add_theme_color_override("font_color", Color.BLACK)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD

func _ready() -> void:
	super._ready()
	setup("Query Group", "Get all nodes in a group.", "group.png", CardVisual.Type.Effect, [
		OutputSlot.new({"default": ["Array"]}),
	], [field_ui, info_label])

func _process(delta: float) -> void:
	super._process(delta)
	invoke_output("default", [get_tree().get_nodes_in_group(group_name)])
