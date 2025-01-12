@tool
extends Node

var camera: Camera2D

func play_sound(sound: Resource) -> void:
	var sound_player = AudioStreamPlayer2D.new()
	sound_player.stream = sound
	get_tree().get_root().add_child(sound_player)
	sound_player.finished.connect(func(): sound_player.queue_free())
	sound_player.play()
