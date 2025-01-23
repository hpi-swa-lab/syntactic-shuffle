extends Node2D

@export var scene: Node2D

@export var timeout = 1.5

var elapsed = 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > timeout:
		var s = scene.duplicate(DUPLICATE_GROUPS|DUPLICATE_SCRIPTS|DUPLICATE_SIGNALS)
		s.global_position = global_position
		s.freeze = false
		get_parent().add_child(s)
		elapsed -= timeout
