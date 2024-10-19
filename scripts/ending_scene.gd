extends Control

func _on_ending_animation_finished() -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")