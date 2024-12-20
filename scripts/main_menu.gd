extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var button_select: AudioStreamPlayer = $ButtonSelect
@onready var animation_player_2 = $AnimationPlayer2

func _ready() -> void:
	animation_player.set_current_animation("opening")
	animation_player.play()

func _on_animation_player_animation_finished(_anim_name) -> void:
	print("Opening finished, playing idel")
	animation_player_2.set_current_animation("idle")
	animation_player_2.play()

func _on_play_button_pressed() -> void:
	if Global.has_visited_scene("intro_scene"):  # Corrected function name
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")
		print("Saw animation 2")
	else:
		get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")
		Global.mark_scene_visited("intro_scene")  # Mark it as visited the first time
		print("NO YOU DIDN'T SEE 2")



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_play_button_mouse_entered() -> void:
	button_select.play()


func _on_credit_button_mouse_entered() -> void:
	button_select.play()

func _on_quit_button_mouse_entered() -> void:
	button_select.play()


func _on_animation_player_2_animation_finished(_anim_name):
	animation_player_2.set_current_animation("idle")
	animation_player_2.play()
