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

var coin_count: int = 0
var multiplier: float = 1.00
var autoButtonActivate: bool = false
var clickLevel: int = 1
var autoClickLevel: int = 1

var idleAnimation = preload("res://resources/heat_button_start_heat_idle_out.ogv")
var clickAnimation = preload("res://resources/heat_button_start_heat_idle_press.ogv")
var isIdle: bool = true

func _ready() -> void:
	turretProgress.value = 0
	turretProgress.max_value = 1000000
	multiplier = 1.00
	multiplierLabel.text = "Multiplier: %.2f x" % multiplier

# Function to format large numbers with suffixes like "k" for thousands, "M" for millions, etc.
func format_large_number(value: int) -> String:
	if value >= 1000000000: # Billions
		return "%.2fB" % (value / 1000000000.0)
	elif value >= 1000000: # Millions
		return "%.2fM" % (value / 1000000.0)
	elif value >= 1000: # Thousands
		return "%.2fK" % (value / 1000.0)
	return str(value)

# Clicking upgrade Function
# Maybe use the following formula? Multiplier = round(1 + 1.00 * pow(clickLevel, 1.10))
func _on_more_click_pressed() -> void:
	var baseCost = 10
	var requiredCoins = round(baseCost + 10.59 * pow(clickLevel, 1.10))

	if coin_count < requiredCoins:
		clickUpgrade.text = "Required coins: %s" % format_large_number(requiredCoins)
		clickUpgrade.disabled = true
	else:
		coin_count -= requiredCoins
		coin.text = "Coins: %s" % format_large_number(coin_count)

		# Increment the level and update the multiplier
		clickLevel += 1
		multiplier = 1 + 0.05 * pow(clickLevel, 1.07)

		# Recalculate the new requiredCoins for the next level
		requiredCoins = round(baseCost + 10.59 * pow(clickLevel, 1.10))
		clickUpgrade.text = "Upgrade: %s coins" % format_large_number(requiredCoins)
		clickUpgrade.disabled = false
		multiplierLabel.text = "Multiplier: %.2f x" % multiplier

	print(requiredCoins)
	print(multiplier)

# Clicking on the money generator
func _on_button_pressed() -> void:
	isIdle = false
	coin.text = "Coins: %s" % format_large_number(coin_count)
	coin_count += round(1 * multiplier)
	video_player.set_stream(clickAnimation)
	video_player.play()
	buttonSFX.play()

	var button = getCoin
	var tween = create_tween()
	var shake_offset_x = randf_range(-10, 10)
	var shake_offset_y = randf_range(-10, 10)

	# Apply the shake effect by tweening the button's position
	var original_position = button.position
	var shake_position = original_position + Vector2(shake_offset_x, shake_offset_y)

	tween.tween_property(getCoin, "position", shake_position, 0.01)
	tween.tween_property(getCoin, "position", original_position, 0.01)

	await get_tree().create_timer(0.1).timeout

	isIdle = true
	ifIdle()
	print("ifIdle function called")

# Clicking on the activation of the auto clicker
func autoButtonUse() -> void:
	if autoButtonActivate == true:
		autoclick.start(0.5)
		autobutton.text = "Auto Click: On!"
	else:
		autoclick.stop()
		autobutton.text = "Auto Click: Off!"

# Clicking on button to shorten/upgrade the autoclicker 
func _on_auto_click_update_pressed() -> void:
	var baseCost = 100
	var autoUp = round(baseCost + 2.53 * pow(autoClickLevel, 1.9))

	print("Upgrade for %d" % autoUp)

	if coin_count < autoUp:
		autoClickUpgrade.text = "Required coins: %s coins" % format_large_number(autoUp)
		autoClickUpgrade.disabled = true
	else:
		coin_count -= autoUp
		coin.text = "Coins: %s" % format_large_number(coin_count)

		autoClickLevel += 1
		autoUp = round(baseCost + 2.53 * pow(autoClickLevel, 1.9))

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

# Should update every time.
func _process(_delta):
	var clickBase = 10
	var autoBase = 100
	var clickUp = round(clickBase + 10.59 * pow(clickLevel, 1.10))
	var autoUp = round(autoBase + 2.53 * pow(autoClickLevel, 1.9))
	var clickText = "Upgrade: %d coins" % clickUp
	var autoText = "Upgrade: %d coins" % autoUp

	# Update the coin text using the formatted large number
	coin.text = "Coins: %s" % format_large_number(coin_count)

	# Update the progress bar based on the coin count
	turretProgress.value = coin_count / turretProgress.max_value * 100 # Scale to percentage

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

# This function is called when the blink timer times out
func _on_blink_timer_timeout() -> void:
	isIdle = not isIdle
	if isIdle:
		video_player.stream = idleAnimation
	else:
		video_player.stream = clickAnimation
	video_player.play()

func ifIdle() -> void:
	var idleTimer = get_tree().create_timer(15.0).timeout

	if isIdle:
		while isIdle:
			video_player.stream = idleAnimation
			video_player.play()

			await get_tree().create_timer(randf_range(7.0, 10.0)).timeout
			print("Play blink animation")
			video_player.stream = idleAnimation
			video_player.play()

			if idleTimer:
				print("Idle is true, and should play idle animation")
				await idleTimer

# Handle when the video animation finishes, freeze on the last frame
func _on_video_player_finished() -> void:
	if isIdle:
		video_player.stop()  # Stop the video
		video_player.frame = video_player.get_stream().get_frame_count() - 1  # Freeze on the last frame
