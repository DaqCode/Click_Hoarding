extends Node

var visited_scenes = {}

func mark_scene_as_visited(scene_name: String) -> void:
	visited_scenes[scene_name] = true

func has_visited_scene(scene_name: String) -> bool:
	return visited_scenes.get(scene_name, false)
