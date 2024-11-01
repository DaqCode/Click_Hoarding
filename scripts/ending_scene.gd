extends Control

@onready var dissapear_animation: AnimationPlayer = $dissapearAnimation

func _on_ending_animation_finished() -> void:
	dissapear_animation.play("dissapear")
	await dissapear_animation.animation_finished
	print("Bye bye played")
	get_tree().change_scene_to_file("res://scenes/eat_a_burger_sponser.tscn")
