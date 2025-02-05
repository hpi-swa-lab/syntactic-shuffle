extends RefCounted
class_name Error

signal close()

func fix_ui(): return null
func get_message() -> String: return "ERROR"

class Generic extends Error:
	var message: String
	func _init(message: String):
		self.message = message
	func get_message(): return message

class CodeCardMissingOutput extends Error:
	var card: CodeCard
	var name: String
	var args: Array
	func _init(card: CodeCard, name: String, args: Array):
		self.name = name
		self.args = args
		self.card = card
	func get_message(): return "Attempted to send to unkown output '{0}'.".format([name])
	func fix_ui():
		var b = Button.new()
		b.text = "Add"
		b.pressed.connect(func():
			var signature = Signature.TriggerSignature.new() if args.is_empty() else Signature.TypeSignature.new(Signature.type_signature(typeof(args[0])))
			card.visual.editor.add_output(name, signature)
			close.emit())
		return b
