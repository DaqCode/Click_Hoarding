extends Node

# Dictionary to track visited scenes
var visited_scenes = {}

# Function to mark a scene as visited
func mark_scene_visited(scene_name: String) -> void:
    visited_scenes[scene_name] = true

# Function to check if a scene was visited
func has_visited_scene(scene_name: String) -> bool:
    return visited_scenes.get(scene_name, false)
