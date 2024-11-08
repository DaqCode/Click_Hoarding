extends Button
@onready var flying_bird: Button = $"."
@onready var flying_timer: Timer = $"../Timers/FlyingTimer"
@onready var flap_timer: Timer = $"../Timers/FlapTimer"

var xPos = position.x 
var yPos = position.y
var canFly = false

const BIRD_ONE = preload("res://images/birb/birdOne.png")
const BIRD_TWO = preload("res://images/birb/birdTwo.png")

const BIRB_1 = preload("res://images/birb/birb1.png")
const BIRB_2 = preload("res://images/birb/birb2.png")

func _ready()-> void:
	flying_timer.wait_time = randf_range(4,10)
	print(flying_timer.wait_time)
	flying_timer.start()

	flap_timer.wait_time = randf_range(0.1,0.4)
	flap_timer.start()
		
func _process(delta) -> void:

	if canFly == true:
		flying_bird.position.x += 175 * delta
		if flying_bird.position.x > 1500:
			flying_bird.position.x = -200
			canFly = false
			flying_timer.wait_time = randf_range(4,10)
			flying_timer.start()
	


func _on_flying_timer_timeout() -> void:
	print("CanFly true")
	canFly = true
	
	
func _on_flap_timer_timeout() -> void:
	flying_bird.icon = BIRD_ONE
	await get_tree().create_timer(randf_range(0.1,0.4)).timeout
	flying_bird.icon = BIRD_TWO
	flap_timer.wait_time = randf_range(0.1,0.4)
	flap_timer.start()
