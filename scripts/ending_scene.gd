extends Control

@onready var byebye: AnimationPlayer = $dissapearAnimation

func _on_ending_animation_finished() -> void:
    byebye.play("dissapear")
    await byebye.animation_finished
    print("Bye bye played")
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")