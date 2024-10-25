extends Control

@onready var coin: Label = $RightSide/CoinLabel
@onready var autoclick: Timer = $Timers/AutoClickTimer
@onready var autobutton: Button = %AutoClick
@onready var getCoin: Button = $RightSide/Button
@onready var multiplierLabel: Label = %MultiplierCount
@onready var clickUpgrade: Button = %MoreClick
@onready var autoClickUpgrade: Button = $RightSide/AutoClickUpdate
@onready var turretProgress: ProgressBar = $TurretBuyTargetBar
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var blinkCount: Timer = $Timers/BlinkTimer
@onready var buttonSFX: AudioStreamPlayer = $SFX/ButtonClickSFX
@onready var timeInt: Label = $RightSide/LabelContainer/TimePanel/TimeIntervalLabel
@onready var randomText: Label = $RandomLabel
@onready var pausePanel: Panel = $PausePanel
@onready var goldenClick: Timer = $Timers/GoldenClick
@onready var goldenClickSFX: AudioStreamPlayer = $SFX/GoldenClickAppear
@onready var goldenClickButton: Button = $GoldenClick
@onready var goldenClickDespawn: Timer = $Timers/BlinkTimerDespawn
@onready var repairTurrent: Button = $RightSide/GridContainer/RepairClick


var coin_count: int = 0
var multiplier: float = 1.00
var autoButtonActivate: bool = false
var clickLevel: int = 1
var autoClickLevel: int = 1

#Animation variables
var idleAnimation = preload("res://resources/heat_button_start_heat_idle_out.ogv")
var clickAnimation = preload("res://resources/heat_button_start_heat_idle_press.ogv")
var staerieAnimation = preload("res://resources/heat_button_example_1_out.ogv")
var billyAnimation = preload("res://resources/heat_button_example_2_out.ogv")
var clownAnimation = preload("res://resources/heat_button_example_3_out.ogv")
var fishAnimation = preload("res://resources/heat_button_example_4_out.ogv")

#SFX variables
var buttonClick = preload("res://resources/sfx/buttonClick.mp3")
var clownClick = preload("res://resources/sfx/Clown Horn Sound Effect Lethal Company.mp3")
var fishClick = preload("res://resources/sfx/FISH.mp3")
var boopClick = preload("res://resources/sfx/Sound Effect - Bloop Cartoon.mp3")
var bonkClick = preload("res://resources/sfx/Bonk Sound Effect.mp3")

var isIdle: bool = true

func _ready() -> void:
	goldenClickButton.disabled = true
	turretProgress.min_value = 0
	turretProgress.max_value = 10000000
	turretProgress.value = 0
	multiplier = 1.00
	multiplierLabel.text = "Multiplier: %.2f x" % multiplier
	timeInt.text = "Click: %.1f" % 1.00
	goldenClick.wait_time = randf_range(10, 15)
	goldenClick.start()


# Function to format large numbers with suffixes like "k" for thousands, "M" for millions, etc.
func format_large_number(value: int) -> String:
	if value >= 1000000000: # Billions
		return "%.1fB" % (value / 1000000000.0)
	elif value >= 1000000: # Millions
		return "%.1fM" % (value / 1000000.0)
	elif value >= 1000: # Thousands
		return "%.1fK" % (value / 1000.0)
	return str(value)


# Clicking upgrade Function
# Maybe use the following formula? Multiplier = round(1 + 1.00 * pow(clickLevel, 1.10))
func _on_more_click_pressed() -> void:
	var baseCost = 10
	var requiredCoins = round(baseCost + 10.59 * pow(clickLevel, 1.10))

	if coin_count < requiredCoins:
		clickUpgrade.text = "Required: %.1f coins" % format_large_number(requiredCoins)
		clickUpgrade.disabled = true
	else:
		coin_count -= requiredCoins
		#Problem, might have to just ignore for now..?
		coin.text = "Coins: %.1f" % format_large_number(coin_count)

		# Increment the level and update the multiplier
		clickLevel += 1
		multiplier = 1 + 0.05 * pow(clickLevel, 1.07)

		# Recalculate the new requiredCoins for the next level
		requiredCoins = round(baseCost + 10.59 * pow(clickLevel, 1.10))
		
		#Problem, might have to just ignore for now..?
		clickUpgrade.text = "Upgrade: %.1f coins" % format_large_number(requiredCoins)
		clickUpgrade.disabled = false
		multiplierLabel.text = "Multiplier: %.1f x" % multiplier

	print(requiredCoins)
	print(multiplier)

# Clicking on the money generator
func _on_button_pressed() -> void:
	isIdle = false
	coin.text = "Coins: %s" % format_large_number(coin_count)
	coin_count += round(1 * multiplier)

	# Randomly select an animation, based on rarity I guess
	var chance = randi() % 1000 + 1
	buttonSFX.volume_db = -10

	if chance <= 1:
		video_player.set_stream(fishAnimation)
		video_player.z_index = 2
		buttonSFX.set_stream(fishClick)
		
	elif chance <= 5:
		video_player.set_stream(clownAnimation)
		buttonSFX.set_stream(clownClick)
		buttonSFX.volume_db = 0

	elif chance <= 50:
		video_player.set_stream(billyAnimation)
		buttonSFX.set_stream(boopClick)
		buttonSFX.volume_db = 0

	elif chance <= 60:
		video_player.set_stream(staerieAnimation)
		buttonSFX.set_stream(bonkClick)

	else:
		video_player.set_stream(clickAnimation)
		buttonSFX.set_stream(buttonClick)

	#Create the +1 effect appearing and leaving.
	randomText.text = "+%.2f Coins" % (1 * multiplier)
	randomText.position = Vector2(randf_range(30.0, 500.0), randf_range(110.0, 548.0))
	randomText.rotation = randf_range(-1.0, 1.0)
	randomText.visible = true
	
	video_player.play()	
	buttonSFX.play()

	await get_tree().create_timer(0.25).timeout
	video_player.z_index = 0

	await buttonSFX.finished
	await get_tree().create_timer(0.25).timeout
	randomText.visible = false
	randomText.rotation = 0.0
	isIdle = true
	

# Clicking on the activation of the auto clicker
func autoButtonUse() -> void:
	if autoButtonActivate == true:
		autoclick.start(autoclick.wait_time)
		autobutton.text = "Auto Click: On!"
	else:
		autoclick.stop()
		autobutton.text = "Auto Click: Off!"


# Clicking on button to shorten/upgrade the autoclicker 
func _on_auto_click_update_pressed() -> void:
	var baseCost = 100
	var autoUp = round(baseCost + 1000 * pow(autoClickLevel, 1.9))

	print("Upgrade for %d" % autoUp)

	if coin_count < autoUp:
		autoClickUpgrade.text = "Required: %.1f coins" % format_large_number(autoUp)
		autoClickUpgrade.disabled = true
	else:
		coin_count -= autoUp
		coin.text = "Coins: %s" % format_large_number(coin_count)

		autoClickLevel += 1
		autoUp = round(baseCost + 1000 * pow(autoClickLevel, 1.9))

		autoClickUpgrade.text = "Upgrade: %s coins" % format_large_number(autoUp)
		autoClickUpgrade.disabled = false

		# Decrease the interval for the autoclicker based on autoClickLevel
		autoclick.wait_time = max(0.01, 1.0 / autoClickLevel * 2) # Minimum time interval of 0.1 seconds
		print("AutoClick Level: %d, Interval: %.2f seconds" % [autoClickLevel, autoclick.wait_time])

# When time expires, repeat to _on_auto_click_pressed
func _on_auto_click_timeout() -> void:
	_on_button_pressed()

	# Restart the autoclicker with the updated interval
	autoclick.start()

# When autoclicker is pressed
func _on_auto_click_pressed() -> void:
	autoButtonActivate = not autoButtonActivate
	autoButtonUse()

# This function is called when the blink timer times out
func _on_blink_timer_timeout() -> void:
	isIdle = not isIdle
	if isIdle:
		video_player.stream = idleAnimation
	else:
		video_player.stream = clickAnimation
	video_player.play()

func _on_video_stream_player_finished() -> void:
	if isIdle:
		await get_tree().create_timer(randf_range(7.0, 10.0)).timeout
		video_player.stream = idleAnimation
		video_player.play()


# Should update every time.
func _process(_delta):
	var clickBase = 10
	var autoBase = 100
	var clickUp = round(clickBase + 10.59 * pow(clickLevel, 1.10))
	var autoUp = round(autoBase + 1000 * pow(autoClickLevel, 1.9))
	var turretUp = 1000000
	var clickText = "Upgrade: %d coins" % clickUp
	var autoText = "Upgrade: %d coins" % autoUp

	# Update the coin text using the formatted large number
	coin.text = "Coins: %s" % format_large_number(coin_count)

	# Update the progress bar based on the coin count
	turretProgress.value = coin_count
	
	# Check if upgrades are available and update button states
	if coin_count < clickUp:
		clickUpgrade.text = "Required coins: %s" % format_large_number(clickUp)
		clickUpgrade.disabled = true
	else:
		clickUpgrade.text = clickText
		clickUpgrade.disabled = false

	if coin_count < autoUp:
		autoClickUpgrade.text = "Required coins: %s" % format_large_number(autoUp)
		autoClickUpgrade.disabled = true
	else:
		autoClickUpgrade.text = autoText
		autoClickUpgrade.disabled = false

	if coin_count < turretUp:
		repairTurrent.text = "Not yet..."
		repairTurrent.disabled = true
	else:
		repairTurrent.text = "Purchase!"
		repairTurrent.disabled = false

	timeInt.text = "Click: %.2f" % autoclick.wait_time 

func _on_pause_pressed() -> void:
	get_tree().paused = true
	pausePanel.visible = true

func _on_resume_pressed() -> void:
	print("Resumed")
	get_tree().paused = false
	pausePanel.visible = false

func _on_golden_click_timeout() -> void:

	goldenClick.wait_time = randf_range(10, 12)

	goldenClickButton.disabled = false
	goldenClickButton.position = Vector2(randf_range(30.0, 500.0), randf_range(110.0, 548.0))

	goldenClickSFX.volume_db = -20.0
	goldenClickSFX.pitch_scale = 0.5
	goldenClickSFX.play()

	await get_tree().create_timer(0.5).timeout
	goldenClickDespawn.wait_time = randf_range(1,2)
	goldenClickDespawn.start()
	print("Golden YEAH CLICK %f" % goldenClick.wait_time)

func _on_golden_click_pressed() -> void:

	var chance = randi() % 3 + 1

	if chance == 1:
		coin_count += 100
		coin.text = "Coins: %s" % format_large_number(coin_count)

	elif chance == 2:
		coin_count += 1000
		coin.text = "Coins: %s" % format_large_number(coin_count)
	
	elif chance == 3:
		coin_count += 10000
		coin.text = "Coins: %s" % format_large_number(coin_count)
	
	else:
		coin_count += 100

	goldenClickButton.disabled = true

	goldenClickSFX.volume_db = -17.5
	goldenClickSFX.pitch_scale = 1.2
	goldenClickSFX.play()

	goldenClick.wait_time = randf_range(3, 5)
	goldenClick.start()
	

	print("Golden Click clicked, going back to waiting again")

func _on_blink_timer_despawn_timeout() -> void:
	goldenClickSFX.pitch_scale = 1.0
	goldenClickSFX.play()

	goldenClickButton.disabled = true
	goldenClickButton.position = Vector2(-1000, -1000) # Off-screen position to "hide" it
	print("Golden click despawned, starting the spawn timer for the next one.")
	goldenClick.wait_time = randf_range(5, 7)
	print("1")
	goldenClick.start()
	print("2")


func _on_repair_click_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ending_scene.tscn")
