extends Control

@onready var idle: AnimationPlayer = $AnimationPlayer2
@onready var button_select: AudioStreamPlayer = $ButtonSelect
@onready var thanks: Panel = $Thanks

var endingCounter = 0

func _ready() -> void:
	idle.play("idle")

func _on_animation_player_animation_finished() -> void:
	idle.play("idle")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")


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
	
func _on_button_pressed() -> void:
	thanks.visible = false
