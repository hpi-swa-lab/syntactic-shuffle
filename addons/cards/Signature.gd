extends RefCounted
class_name Signature

var d:
	get: return get_description()
func compatible_with(other: Signature) -> bool: return false
func get_description() -> String: return ""
func serialize_gdscript() -> String: return ""
func provides_data() -> bool: return false
func has_iterator() -> bool: return false
func eq(other: Signature): return false
func compatible_with_command(other: CommandSignature): return false #other.arg and other.arg.compatible_with(self)
func compatible_with_trigger(other: TriggerSignature): return false
func compatible_with_generic(other: GenericTypeSignature): return false
func compatible_with_type(other: TypeSignature): return false
func compatible_with_struct(other: StructSignature): return false
func compatible_with_group(other: GroupSignature): return false
func compatible_with_iterator(other: IteratorSignature): return other.type.compatible_with(self)
## Given a set of incoming cards, make this Signature concrete, i.e., non-generic
func make_concrete(incoming: Array[Signature], aggregate = false) -> Array[Signature]:
	var has_iterator = not aggregate and incoming.any(func(s): return s is IteratorSignature)
	return sig_array([wrap_iterator()] if has_iterator else [self])
func unwrap_iterator(): return self
func wrap_iterator(): return IteratorSignature.new(self)
func unwrap_command(): return self

static func sig_array(array: Array):
	assert(array.is_empty() or array[0] is Signature)
	return Array(array, TYPE_OBJECT, &"RefCounted", Signature)

static func deduplicate(array) -> Array[Signature]:
	var out = [] as Array[Signature]
	for s in array:
		if not out.any(func (s2): return s.eq(s2)):
			out.push_back(s)
	return out

class OutputAnySignature extends Signature:
	func get_description(): return "[any]"
	func compatible_with(other: Signature): return true
	func eq(other: Signature): return other is OutputAnySignature
	func compatible_with_command(other: CommandSignature): return true
	func compatible_with_trigger(other: TriggerSignature): return true
	func compatible_with_generic(other: GenericTypeSignature): return true
	func compatible_with_type(other: TypeSignature): return true
	func compatible_with_struct(other: StructSignature): return true
	func compatible_with_group(other: GroupSignature): return true
	func compatible_with_iterator(other: IteratorSignature): return true
	func make_concrete(incoming: Array[Signature], aggregate = false) -> Array[Signature]:
		#return incoming
		if incoming.is_empty():
			return sig_array([self])
		else: return incoming
	func serialize_gdscript(): return "OutputAnySignature.new()"

static var _custom_class_hierarchy = null
static func _ensure_custom_class_hierarchy():
	if _custom_class_hierarchy: return
	_custom_class_hierarchy = {}
	for c in ProjectSettings.get_global_class_list():
		_custom_class_hierarchy[c["class"]] = c["base"]

class TypeSignature extends Signature:
	var type: String
	func _init(type: String):
		self.type = type
	func get_description(): return type
	func serialize_gdscript(): return "t(\"{0}\")".format([type])
	func provides_data(): return true
	func eq(other: Signature): return other is TypeSignature and other.type == type
	func compatible_with(other: Signature): return other.compatible_with_type(self)
	func compatible_with_generic(other: GenericTypeSignature): return true
	func compatible_with_type(other: TypeSignature):
		_ensure_custom_class_hierarchy()
		if type == "Variant": return true
		var name = other.type
		while name:
			if name == type: return true
			elif ClassDB.class_exists(name): name = ClassDB.get_parent_class(name)
			elif _custom_class_hierarchy.has(name): name = _custom_class_hierarchy[name]
			else: break
		return false
	func compatible_with_struct(other: StructSignature): return other.compatible_with_type(self)

class CommandSignature extends Signature:
	var arg: Signature
	var command: String
	func _init(command: String, arg: Signature):
		self.command = command
		self.arg = arg if arg else TriggerSignature.new()
	func has_iterator(): return arg.has_iterator()
	func serialize_gdscript(): return "cmd(\"{0}\"{1})".format([command, ", " + arg.serialize_gdscript() if arg else ""])
	func provides_data(): return arg.provides_data()
	func eq(other: Signature): return other is CommandSignature and other.arg.eq(arg) and other.command == command
	func get_description(): return "{0}![{1}]".format([command, arg.get_description()]) if arg else ">{0}".format([command])
	func compatible_with(other: Signature): return other.compatible_with_command(self)
	func compatible_with_command(other: CommandSignature):
		if command == "*": return true
		return other.command == command and other.arg.compatible_with(arg)
	func unwrap_command(): return arg
	func make_concrete(incoming: Array[Signature], aggregate = false) -> Array[Signature]:
		incoming = sig_array(incoming.map(func (s): return s.unwrap_command()))
		return sig_array(arg.make_concrete(incoming, aggregate).map(func (s): return CommandSignature.new(command, s)))

class GenericTypeSignature extends Signature:
	var name: String
	func _init(name = "T"):
		self.name = name
	func get_description(): return "*"
	func provides_data(): return true
	func serialize_gdscript(): return "any(\"{0}\")".format([name])
	func eq(other: Signature): return other is GenericTypeSignature
	func compatible_with(other: Signature): return other.compatible_with_generic(self)
	func compatible_with_type(other: Signature): return true
	func compatible_with_generic(other: GenericTypeSignature): return true
	func make_concrete(incoming: Array[Signature], aggregate = false):
		incoming = incoming.filter(func (i): return i.provides_data())
		if incoming.is_empty(): return super.make_concrete(incoming, aggregate)
		
		var matching = incoming.map(func (s): return s.unwrap_command()).filter(func(s): return s.compatible_with(self))
		var has_iterator = not aggregate and incoming.any(func(s): return s is IteratorSignature)
		if has_iterator:
			matching = matching.map(func (s): return s.wrap_iterator())
		elif aggregate:
			matching = matching.map(func (s): return s.unwrap_iterator())
		return sig_array(matching)

class TriggerSignature extends Signature:
	func get_description(): return "[TRIGGER]"
	func serialize_gdscript(): return "trg()"
	func eq(other: Signature): return other is TriggerSignature
	func compatible_with(other: Signature): return other.compatible_with_trigger(self)
	func compatible_with_trigger(other: TriggerSignature): return true

class IteratorSignature extends Signature:
	var type: Signature
	func _init(type: Signature):
		self.type = type
	func has_iterator(): return true
	func provides_data(): return type.provides_data()
	func serialize_gdscript(): return "it({0})".format([type.serialize_gdscript()])
	func eq(other: Signature): return other is IteratorSignature and type.eq(other.type)
	func compatible_with(other: Signature): return other.compatible_with_iterator(self)
	func get_description(): return "Iterator<{0}>".format([type.get_description()])
	func compatible_with_iterator(other: IteratorSignature): return other.type.compatible_with(type)
	func make_concrete(incoming: Array[Signature], aggregate = false) -> Array[Signature]:
		return sig_array(type.make_concrete(sig_array(incoming.map(func (s): return s.unwrap_iterator())), true).map(func (s): return IteratorSignature.new(s)))
	func unwrap_iterator(): return type
	func wrap_iterator(): return self

class VoidSignature extends Signature:
	func eq(other: Signature): return other is VoidSignature
	func get_description(): return "<void>"
	func serialize_gdscript(): return "none()"
	func compatible_with(other: Signature): return false

class GroupSignature extends Signature:
	var group_names: Array[StringName]
	func _init(group_names: Array[StringName]): self.group_names = group_names
	func get_description(): return "Group({0})".format([",".join(group_names)])
	func serialize_gdscript(): return "grp(" + ", ".join(group_names) + ")"
	func provides_data(): return true
	func eq(other: Signature): return other is GroupSignature and other.group_names == group_names
	func compatible_with(other: Signature): return other.compatible_with_group(self)
	func compatible_with_group(other: GroupSignature): return group_names.any(func(g): return other.group_names.has(g))

class StructSignature extends Signature:
	var props: Dictionary[String, Signature]
	var methods: Array[String]
	func _init(props: Dictionary[String, Signature], methods: Array[String]):
		self.props = props
		self.methods = methods
	func provides_data(): return true
	func eq(other: Signature): return other is StructSignature and other.props == props and other.methods == methods
	func serialize_gdscript(): push_error("not yet implemented")
	func get_description():
		var out = "@"
		for prop in props: out += "{0}:{1};".format([prop, props[prop].get_description()])
		for name in methods: out += "{0}();".format([name])
		return out
	func compatible_with(other: Signature): return other.compatible_with_struct(self)
	func compatible_with_struct(other: StructSignature):
		if props.size() != other.props.size(): return false
		if methods.size() != other.methods.size(): return false
		# FIXME subset should be legal
		for prop in props:
			if not other.props.has(prop) or not other.props[prop].compatible_with(props[prop]): return false
		for method in methods:
			if not other.methods.has(method): return false
		return true
	func compatible_with_type(other: TypeSignature):
		var type_props = ClassDB.class_get_property_list(other.type)
		var type_methods = ClassDB.class_get_method_list(other.type)
		for name in props:
			if not _list_has_prop(type_props, name): return false
		for name in methods:
			if not _list_has_method(type_methods, name): return false
		return true
	func _list_has_prop(type_props, name):
		for prop in type_props:
			if prop["name"] == name and TypeSignature.new(type_signature(prop["type"])).compatible_with(props[name]):
				return true
		return false
	func _list_has_method(type_methods, name):
		for prop in type_methods:
			if prop["name"] == name: return true
		return false

class Iterator extends RefCounted:
	var keys_list
	var values_list
	func _init(list):
		keys_list = list
		values_list = list

static func signature_for_dict(dict: Dictionary):
	if dict["args"].is_empty():
		return Signature.TriggerSignature.new()
	return Signature.TypeSignature.new(type_signature(dict["args"][0]["type"]))

static func signature_for_type(type):
	return Signature.TypeSignature.new(type_signature(type))

static func signature_for_value(value):
	return signature_for_type(typeof(value))

static func type_signature(type, inverse = false):
	var mapping = {
		TYPE_NIL: "nil",
		TYPE_BOOL: "bool",
		TYPE_INT: "int",
		TYPE_FLOAT: "float",
		TYPE_STRING: "String",
		TYPE_VECTOR2: "Vector2",
		TYPE_VECTOR2I: "Vector2i",
		TYPE_RECT2: "Rect2",
		TYPE_RECT2I: "Rect2i",
		TYPE_VECTOR3: "Vector3",
		TYPE_VECTOR3I: "Vector3i",
		TYPE_TRANSFORM2D: "Transform2D",
		TYPE_VECTOR4: "Vector4",
		TYPE_VECTOR4I: "Vector4i",
		TYPE_PLANE: "Plane",
		TYPE_QUATERNION: "Quaternion",
		TYPE_AABB: "AABB",
		TYPE_BASIS: "Basis",
		TYPE_TRANSFORM3D: "Transform3D",
		TYPE_PROJECTION: "Projection",
		TYPE_COLOR: "Color",
		TYPE_STRING_NAME: "StringName",
		TYPE_NODE_PATH: "NodePath",
		TYPE_RID: "RID",
		TYPE_OBJECT: "Object",
		TYPE_CALLABLE: "Callable",
		TYPE_SIGNAL: "Signal",
		TYPE_DICTIONARY: "Dictionary",
		TYPE_ARRAY: "Array",
		TYPE_PACKED_BYTE_ARRAY: "PackedByteArray",
		TYPE_PACKED_INT32_ARRAY: "PackedInt32Array",
		TYPE_PACKED_INT64_ARRAY: "PackedInt64Array",
		TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32Array",
		TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64Array",
		TYPE_PACKED_STRING_ARRAY: "PackedStringArray",
		TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2Array",
		TYPE_PACKED_VECTOR3_ARRAY: "packedVector3Array",
		TYPE_PACKED_COLOR_ARRAY: "PackedColorArray",
		TYPE_PACKED_VECTOR4_ARRAY: "PackedVector4Array",
	}
	if inverse:
		for key in mapping:
			if mapping[key] == type: return key
	else:
		return mapping[type]

static func data_to_expression(data) -> String:
	if data is Vector2:
		return "Vector2" + str(data)
	if data is String:
		#return "\"" + data.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
		return "\"" + data.c_escape() + "\""
	if data == null:
		return "null"
	if data is Array:
		return "[" + ", ".join(data.map(data_to_expression)) + "]"
	if data is Signature:
		return data.serialize_gdscript()
	if data is Callable:
		if data.is_custom(): return "null"
	if data is Object: return "null"
	return str(data)

static func signatures_equal(a: Array[Signature], b: Array[Signature]):
	if a.size() != b.size(): return false
	for i in range(0, a.size()):
		if not a[i].eq(b[i]): return false
	return true
