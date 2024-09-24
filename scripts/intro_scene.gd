extends Control

@onready var introAnimation: VideoStreamPlayer = $HeatIntro

func _on_ready() -> void:
	introAnimation.play()

func _on_heat_intro_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
