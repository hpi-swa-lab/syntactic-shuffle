@tool
extends Card
class_name CellCard

var out_card: OutCard

@export var data: Variant = null
@export var type: String = "":
	get: return type
	set(v):
		type = v
		if v:
			get_out_card().has_static_signature = true
			get_out_card().signature = [v] as Array[String]
		else:
			get_out_card().has_static_signature = false

func get_out_card():
	if not out_card: out_card = OutCard.new()
	return out_card

func s():
	title("Data Cell")
	description("Store or piece of data.")
	icon("number.png")
	
	var code_card = CodeCard.create(["*"], func (card, args):
		data = args[0]
		card.output([args[0]]))
	code_card.c(get_out_card())
	
	var override_card = InCard.command("store", "*")
	override_card.c(code_card)
	
	var trigger_code_card = CodeCard.create(["*"], func (card): card.output([data]))
	trigger_code_card.c(get_out_card())
	
	var trigger_card = InCard.trigger()
	trigger_card.c(trigger_code_card)
