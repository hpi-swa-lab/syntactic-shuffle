@tool
extends Card
class_name CellCard

var out_card: OutCard

@export var data: Variant = null
@export var type: String = "":
	get: return type
	set(v):
		type = v
		if out_card:
			if v:
				out_card.has_static_signature = true
				out_card.signature = [v] as Array[String]
			else:
				out_card.has_static_signature = false

func s():
	title("Data Cell")
	description("Store or piece of data.")
	icon("number.png")
	
	out_card = OutCard.new()
	# refresh type info
	self.type = type
	
	var code_card = CodeCard.create(["*"], func (card, args):
		data = args[0]
		card.output([args[0]]))
	code_card.c(out_card)
	
	var override_card = InCard.command("store", "*")
	override_card.c(code_card)
	
	var trigger_code_card = CodeCard.create(["*"], func (card): card.output([data]))
	trigger_code_card.c(out_card)
	
	var trigger_card = InCard.trigger()
	trigger_card.c(trigger_code_card)
