extends Button
@onready var flying_bird = $"."

var xPos = position.x 
var yPos = position.y

	
func _process(delta) -> void:
	flying_bird.position.x += 100 * delta
	
