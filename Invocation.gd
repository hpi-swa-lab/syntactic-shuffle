extends RefCounted
class_name Invocation

## The global scope for e.g. remembered values
static var GLOBAL = Invocation.new()

class Remembered extends RefCounted:
	var args
	var signature: Signature
	func _init(v: Array, s: Signature):
		args = v
		signature = s
	func clear():
		args = null
		signature = null
	func valid():
		if signature == null: return false
		for arg in args:
			# guard against freed objects to which we remember references
			if not is_instance_valid(arg) and typeof(arg) == TYPE_OBJECT:
				signature = null
				args = null
				return false
		return true

var remembered: Array[Remembered] = []
var parent: Invocation = null

func _init(p = null) -> void:
	self.parent = p if p else GLOBAL

func remember(signature: Signature, args: Array):
	var r = Remembered.new(args, signature)
	remembered.push_back(r)
	return r

func is_child_of(i: Invocation):
	if self == i: return true
	if not parent: return false
	return parent.is_child_of(i)

func pop():
	# FIXME should only clear if we do not return a new parent
	# for r in remembered: r.clear()
	return self

func push():
	return self
