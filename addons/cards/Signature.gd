extends Object
class_name Signature

func d(): return get_description()
func compatible_with(other: Signature) -> bool: return false
func get_description() -> String: return ""
func serialize_gdscript() -> String: return ""
func provides_data() -> bool: return false
func compatible_with_command(other: CommandSignature): return false
func compatible_with_trigger(other: TriggerSignature): return false
func compatible_with_generic(other: GenericTypeSignature): return false
func compatible_with_type(other: TypeSignature): return false
func compatible_with_struct(other: StructSignature): return false
func compatible_with_group(other: GroupSignature): return false
func compatible_with_iterator(other: IteratorSignature): return other.type.compatible_with(self)

class OutputAnySignature extends Signature:
	func get_description(): return "* -> out"
	func compatible_with(other: Signature): return true
	func compatible_with_command(other: CommandSignature): return true
	func compatible_with_trigger(other: TriggerSignature): return true
	func compatible_with_generic(other: GenericTypeSignature): return true
	func compatible_with_type(other: TypeSignature): return true
	func compatible_with_struct(other: StructSignature): return true
	func compatible_with_group(other: GroupSignature): return true
	func compatible_with_iterator(other: IteratorSignature): return true

class TypeSignature extends Signature:
	var type: String
	func _init(type: String):
		self.type = type
	func get_description(): return type
	func serialize_gdscript(): return "t(\"{0}\")".format([type])
	func provides_data(): return true
	func compatible_with(other: Signature): return other.compatible_with_type(self)
	func compatible_with_generic(other: GenericTypeSignature): return true
	func compatible_with_type(other: TypeSignature):
		var name = other.type
		while name:
			if name == type: return true
			elif ClassDB.class_exists(name): name = ClassDB.get_parent_class(name)
			else: break
		return false
	func compatible_with_struct(other: StructSignature): return other.compatible_with_type(self)

class CommandSignature extends Signature:
	var arg: Signature
	var command: String
	func _init(command: String, arg: Signature):
		self.command = command
		self.arg = arg if arg else TriggerSignature.new()
	func serialize_gdscript(): return "cmd(\"{0}\"{1})".format([command, ", " + arg.serialize_gdscript() if arg else ""])
	func provides_data(): return arg.provides_data()
	func get_description(): return ">{0}[{1}]".format([command, arg.get_description()]) if arg else ">{0}".format([command])
	func compatible_with(other: Signature): return other.compatible_with_command(self)
	func compatible_with_command(other: CommandSignature):
		return other.command == command and arg.compatible_with(other.arg)

class GenericTypeSignature extends Signature:
	func get_description(): return "*"
	func provides_data(): return true
	func serialize_gdscript(): return "any()"
	func compatible_with(other: Signature): return other.compatible_with_generic(self)
	func compatible_with_type(other: Signature): return true
	func compatible_with_generic(other: GenericTypeSignature): return true

class TriggerSignature extends Signature:
	func get_description(): return "[TRIGGER]"
	func serialize_gdscript(): return "trg()"
	func compatible_with(other: Signature): return other.compatible_with_trigger(self)
	func compatible_with_trigger(other: TriggerSignature): return true

class IteratorSignature extends Signature:
	var type: Signature
	func _init(type: Signature):
		self.type = type
	func serialize_gdscript(): return ""
	func compatible_with(other: Signature): return other.compatible_with_iterator(self)
	func get_description(): return "Iterator<{0}>".format([type.get_description()])
	func compatible_with_iterator(other: IteratorSignature): return other.type.compatible_with(type)

class VoidSignature extends Signature:
	func get_description(): return "<void>"
	func serialize_gdscript(): return "none()"
	func compatible_with(other: Signature): return false

class GroupSignature extends Signature:
	var group_names: Array[StringName]
	func _init(group_names: Array[StringName]): self.group_names = group_names
	func get_description(): return "Group({0})".format([",".join(group_names)])
	func serialize_gdscript(): return "grp(" + ", ".join(group_names) + ")"
	func provides_data(): return true
	func compatible_with(other: Signature): return other.compatible_with_group(self)
	func compatible_with_group(other: GroupSignature): return group_names.any(func(g): return other.group_names.has(g))

class StructSignature extends Signature:
	var props: Dictionary[String, Signature]
	var methods: Array[String]
	func _init(props: Dictionary[String, Signature], methods: Array[String]):
		self.props = props
		self.methods = methods
	func provides_data(): return true
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
			if prop["name"] == name and TypeSignature.new(type_to_string(prop["type"])).compatible_with(props[name]):
				return true
		return false
	func _list_has_method(type_methods, name):
		for prop in type_methods:
			if prop["name"] == name: return true
		return false

func type_to_string(type):
	match type:
		TYPE_NIL: return "nil"
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "string"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_RECT2: return "Rect2"
		TYPE_RECT2I: return "Rect2i"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_VECTOR4: return "Vector4"
		TYPE_VECTOR4I: return "Vector4i"
		TYPE_PLANE: return "Plane"
		TYPE_QUATERNION: return "Quaternion"
		TYPE_AABB: return "AABB"
		TYPE_BASIS: return "Basis"
		TYPE_TRANSFORM3D: return "Transform3D"
		TYPE_PROJECTION: return "Projection"
		TYPE_COLOR: return "Color"
		TYPE_STRING_NAME: return "StringName"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_RID: return "RID"
		TYPE_OBJECT: return "Object"
		TYPE_CALLABLE: return "Callable"
		TYPE_SIGNAL: return "Signal"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
		TYPE_PACKED_BYTE_ARRAY: return "PackedByteArray"
		TYPE_PACKED_INT32_ARRAY: return "PackedInt32Array"
		TYPE_PACKED_INT64_ARRAY: return "PackedInt64Array"
		TYPE_PACKED_FLOAT32_ARRAY: return "PackedFloat32Array"
		TYPE_PACKED_FLOAT64_ARRAY: return "PackedFloat64Array"
		TYPE_PACKED_STRING_ARRAY: return "PackedStringArray"
		TYPE_PACKED_VECTOR2_ARRAY: return "PackedVector2Array"
		TYPE_PACKED_VECTOR3_ARRAY: return "packedVector3Array"
		TYPE_PACKED_COLOR_ARRAY: return "PackedColorArray"
		TYPE_PACKED_VECTOR4_ARRAY: return "PackedVector4Array"
		_: assert(false, "unknown type")
