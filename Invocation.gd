extends RefCounted
class_name Invocation

class Remembered extends RefCounted:
	var value
	var signature
	func clear():
		value = null
		signature = null

var remembered: Array[Remembered] = []
var parent: Invocation = null

func _init(parent = null) -> void:
	self.parent = parent

func pop():
	for r in remembered: r.clear()
	if parent: return parent
	else:
		# For example the SignalCard has to "ascend" out of itself
		return Invocation.new()

func push():
	return Invocation.new(self)
