extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("reveal")
	Global.mark_scene_visited("eat_a_burger_sponser")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu2.tscn")
