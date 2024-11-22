extends Button
@onready var flying_bird: Button = $"."
@onready var flying_timer: Timer = $"../Timers/FlyingTimer"
@onready var flap_timer: Timer = $"../Timers/FlapTimer"
@onready var chirp: AudioStreamPlayer = %BirdChips

var xPos = position.x 
var yPos = position.y
var canFly = false

var whichBird = 0

#Yellow
const BIRD_ONE = preload("res://images/birb/birdOne.png")
const BIRD_TWO = preload("res://images/birb/birdTwo.png")

#Blue
const BIRB_1 = preload("res://images/birb/birb1.png")
const BIRB_2 = preload("res://images/birb/birb2.png")

#SFX
const YELLOW_CHIRP = preload("res://resources/sfx/monkey.mp3")
const BLUE_CHIRP = preload("res://resources/sfx/moreSpecificSFX/bird.mp3")

func _ready()-> void:

	whichBird = randi_range(1,2)

	flying_timer.wait_time = randf_range(150,300)
	print(flying_timer.wait_time)
	flying_timer.start()

	flap_timer.wait_time = randf_range(0.1,0.2)
	flap_timer.start()
		
func _process(delta) -> void:
	
	if canFly == true:
		flying_bird.position.x += 175 * delta
		if flying_bird.position.x > 1200:
			flying_bird.position.x = -200
			canFly = false
			flying_timer.wait_time = randf_range(150,300)
			flying_timer.start()
			whichBird = randi_range(1,2)
			
		if flying_bird.position.y < 100:
			flying_bird.position.y += 25 * delta
		else:
			flying_bird.position.y -= 25 * delta

func _on_flying_timer_timeout() -> void:
	print("CanFly true")
	flying_bird.disabled = false
	canFly = true
	
	
func _on_flap_timer_timeout() -> void:
	match whichBird:
		1:
			#BLUE BIRD
			flying_bird.icon = BIRB_1
			await get_tree().create_timer(randf_range(0.1,0.2)).timeout
			flying_bird.icon = BIRB_2
			flap_timer.wait_time = randf_range(0.1,0.2)
			flap_timer.start()
		2:
			#YELLOWBIRD
			flying_bird.icon = BIRD_ONE
			await get_tree().create_timer(randf_range(0.1,0.2)).timeout
			flying_bird.icon = BIRD_TWO
			flap_timer.wait_time = randf_range(0.1,0.2)
			flap_timer.start()

	
func _on_pressed() -> void:
	match whichBird:
		1:
			#YELLOW
			chirp.set_stream(YELLOW_CHIRP)
			chirp.play()
			flying_bird.disabled = true
		2:	
			#BLUE
			chirp.set_stream(BLUE_CHIRP)
			chirp.play()
			flying_bird.disabled = true
