extends Control

@onready var idle: AnimationPlayer = $AnimationPlayer2

func _ready() -> void:
	idle.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	idle.play("idle")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
