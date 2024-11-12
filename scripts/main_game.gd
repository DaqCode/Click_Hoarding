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
@onready var golden_click_pef: GPUParticles2D = $GoldenClick/GoldenClickPEF
@onready var upgrade_sfx: AudioStreamPlayer = $SFX/UpgradeSFX
@onready var upgrade_pfx: GPUParticles2D = %UpgradePFX
@onready var pauseLabel: Label = $PausePanel/Label
@onready var click_pef: GPUParticles2D = $RightSide/Button/ClickPEF
@onready var enemy_spawn_timer: Timer = $Timers/EnemySpawnTimer
@onready var enemy_random_spawn: Button = $EnemyRandomSpawn
@onready var health_bar: ProgressBar = $EnemyRandomSpawn/HealthBar
@onready var enemy_bite: Timer = $Timers/EnemyBite
@onready var bite_text: Label = $BiteText
@onready var amount_lost: Label = $BiteText/AmountLost
@onready var monster_spawn: AudioStreamPlayer = $SFX/MonsterSpawn
@onready var monster_death: AudioStreamPlayer = $SFX/MonsterDeath
@onready var monster_growl: AudioStreamPlayer = $SFX/MonsterGrowl
@onready var monster_bite: AudioStreamPlayer = $SFX/MonsterBite
@onready var monster_hit: AudioStreamPlayer = $SFX/MonsterHit
@onready var monster_killed: AudioStreamPlayer = $SFX/MonsterKilled
@onready var pixel_blood: GPUParticles2D = $EnemyRandomSpawn/PixelBlood
@onready var music: AudioStreamPlayer = $Music/Music1
@onready var music2: AudioStreamPlayer = $Music/PauseMenu

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

#Music Variables
var MUSIC_1 = preload("res://resources/music/gameMusicforGameScene/music1.mp3")
var MUSIC_2 = preload("res://resources/music/gameMusicforGameScene/music2.mp3")
var MUSIC_3 = preload("res://resources/music/gameMusicforGameScene/music3.mp3")
var MUSIC_4 = preload("res://resources/music/gameMusicforGameScene/coverless-book-lofi-186307.mp3")
var MUSIC_5 = preload("res://resources/music/gameMusicforGameScene/lofi-chill-melancholic-259764.mp3")

#SFX variables
var buttonClick = preload("res://resources/sfx/buttonClick.mp3")
var clownClick = preload("res://resources/sfx/Clown Horn Sound Effect Lethal Company.mp3")
var fishClick = preload("res://resources/sfx/FISH.mp3")
var boopClick = preload("res://resources/sfx/Sound Effect - Bloop Cartoon.mp3")
var bonkClick = preload("res://resources/sfx/Bonk Sound Effect.mp3")

#Image variables
const MENU1 = preload("res://images/menuImage/menu_png_1_test.png")
const MENU2 = preload("res://images/menuImage/menu_png_2_test.png")
const MENU3 = preload("res://images/menuImage/menu_png_3_test.png")
const MENU4 = preload("res://images/menuImage/menu_png_4_test_wtf.png")

var isIdle: bool = true

func _ready() -> void:
	
	var randomMusic = randi_range(1,5)
	match randomMusic:
		1:
			music.set_stream(MUSIC_1)
		2:
			music.set_stream(MUSIC_2)
		3:
			music.set_stream(MUSIC_3)
		4:
			music.set_stream(MUSIC_4)
		5:
			music.set_stream(MUSIC_5)
	
	music.playing = true
	goldenClickButton.disabled = true
	
	turretProgress.min_value = 0
	turretProgress.max_value = 100000
	turretProgress.value = 0
	
	multiplier = 1.00
	multiplierLabel.text = "Multiplier: %.2f x" % multiplier
	
	timeInt.text = "Click: %.1f" % 1.00
	
	goldenClick.wait_time = randf_range(10, 15)
	goldenClick.start()
	
	enemy_spawn_timer.wait_time = randf_range(5, 6)
	enemy_spawn_timer.start()
	enemy_random_spawn.disabled = true
	health_bar.visible = false
	
	bite_text.visible = false

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
	var requiredCoins = round(baseCost + 25.5 * pow(clickLevel, 1.10))

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
		multiplierLabel.text = "Multiplier: %.2f x" % multiplier
		upgrade_sfx.play()
		upgrade_pfx.emitting = true
	print(requiredCoins)
	print(multiplier)

# Clicking on the money generator
func _on_button_pressed() -> void:
	click_pef.emitting = true
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

		#Needs fixing
		autoClickUpgrade.text = "Upgrade: %.1f coins" % format_large_number(autoUp)
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
	var clickUp = round(clickBase + 25.5 * pow(clickLevel, 1.10))
	var autoUp = round(autoBase + 1000 * pow(autoClickLevel, 1.9))
	var turretUp = 100000
	var clickText = "Upgrade: %d coins" % clickUp
	var autoText = "Upgrade: %d coins" % autoUp

	# Update the coin text using the formatted large number
	coin.text = "Coins: %.s" % format_large_number(coin_count)

	# Update the progress bar based on the coin count
	turretProgress.value = coin_count
	
	# Check if upgrades are available and update button states
	if coin_count < clickUp:
		clickUpgrade.text = "Required coins: %.s" % format_large_number(clickUp)
		clickUpgrade.disabled = true
	else:
		clickUpgrade.text = clickText
		clickUpgrade.disabled = false

	if coin_count < autoUp:
		autoClickUpgrade.text = "Required coins: %.s" % format_large_number(autoUp)
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
	
	var randomStatement = randi_range(1,15)
	var randomImage = randi_range(1,4)
	
	match randomImage:
		1:
			$PausePanel/TextureRect.texture = MENU1
			$PausePanel/TextureRect.position = Vector2(-327.5, -118.5)
		2:
			$PausePanel/TextureRect.texture = MENU2
			$PausePanel/TextureRect.position = Vector2(-364.5, -64.5)
		3:
			$PausePanel/TextureRect.texture = MENU3
			$PausePanel/TextureRect.position = Vector2(-354.5, -134.5)
		4:
			$PausePanel/TextureRect.texture = MENU4
			$PausePanel/TextureRect.position = Vector2(-364.5, -64.5)
	
	match randomStatement:
		1:
			pauseLabel.text = "The golden clicks all give you different amounts depending on how much coins you have now."
		2:
			pauseLabel.text = "This took a month or 2 or 3 to make. It was fun to make though. I hope you enjoy."
		3:
			pauseLabel.text = "Yes, you can use an autocicker. Things might break though."
		4:
			pauseLabel.text = "What's the average time to beat this game? Probably a bit less than an hour."
		5:
			pauseLabel.text = "There's not much lore to Heat himself. Neither is there to Staerie."
		6:
			pauseLabel.text = "Yes, Heat does live rent free in my head and is the average goof ball."
		7:
			pauseLabel.text = "Every click of the button will give you a chance to get a rare animation. Find em all?"
		8:
			pauseLabel.text = "If you think about it, there's thoughts in a thought..."
		9:
			pauseLabel.text = "Man, being a game developer is kinda hard, but it's fun."
		10:
			pauseLabel.text = "It's hard to balance a game like this so well. How did Cookie Clicker do it, I ponder."
		11:
			pauseLabel.text = "Honestly, I'm more preplexed that I managed to do all this. Granted, I know I could have done more."
		12:
			pauseLabel.text = "Chip break huh?"
		13:
			pauseLabel.text = "Honestly, I'm not even sure if I coded all this right. I just, kinda did it."
		14:
			pauseLabel.text = "Hmmmmm... Promotional areas, maybe Youtube or Reddit? You should go check them out?"
		15:
			pauseLabel.text = "If you wanna know, there's a secret on the next game I work on if you beat this. Good luck!"
	
	music2.playing = true

func _on_resume_pressed() -> void:
	music2.playing = false
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
	goldenClickDespawn.paused = false
	goldenClickDespawn.wait_time = randf_range(1,2)
	goldenClickDespawn.start()
	print("Golden YEAH CLICK %f" % goldenClickDespawn.wait_time)

func _on_golden_click_pressed() -> void:
	goldenClickDespawn.paused = true
	goldenClickDespawn.wait_time = randf_range(1,2)
		
	if  coin_count <= 1000:
		coin_count += randi_range(750,900)
		coin.text = "Coins: %s" % format_large_number(coin_count)
	
	elif coin_count >= 1000:
		coin_count += randi_range(5000,7500)
		coin.text = "Coins: %s" % format_large_number(coin_count)
	
	elif coin_count >= 10000:
		coin_count += randi_range(10000,15000)
		coin.text = "Coins: %s" % format_large_number(coin_count)
		
	elif coin_count >= 100000:
		coin_count += randi_range(33333,99999)
		coin.text = "Coins: %s" % format_large_number(coin_count)
	
	elif coin_count > 1000000:
		coin_count += randi_range(5555555,9999000)
		coin.text = "Coins: %s" % format_large_number(coin_count)
		
	else:
		coin_count += 100
		coin.text = "Coins: %s" % format_large_number(coin_count)
		
	golden_click_pef.emitting = true
	
	goldenClickButton.disabled = true

	goldenClickSFX.volume_db = -17.5
	goldenClickSFX.pitch_scale = 1.2
	goldenClickSFX.play()

	goldenClick.wait_time = randf_range(10, 15)
	goldenClick.start()

func _on_repair_click_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ending_scene.tscn")


func _on_blink_timer_despawn_timeout() -> void:
	
	goldenClickSFX.volume_db = -20.0
	goldenClickSFX.pitch_scale = 2.0
	goldenClickSFX.play()
	
	goldenClickButton.disabled = true
	print("despawned")
	goldenClick.wait_time = randf_range(10,15)
	goldenClick.start()
	print("Respawn for %f" % goldenClick.wait_time)


func _on_btmm_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu2.tscn")


func _on_enemy_random_spawn_pressed():
	enemy_random_spawn.position = Vector2(randf_range(300,700), randf_range(300, 400)) 
	monster_hit.play()
	pixel_blood.emitting = true
	
	if (!health_bar.value == 1):
		health_bar.value -=1
	else:
		print("enemy died")
		enemy_bite.stop()
		
		enemy_random_spawn.disabled = true
		health_bar.value = 5
		health_bar.visible = false
		
		enemy_spawn_timer.wait_time = randf_range(50, 100)
		print(enemy_spawn_timer.wait_time)
		enemy_spawn_timer.start()
		
		if coin_count <= 1000:
			coin_count += randi_range(750,1250)
			coin.text = "Coins: %s" % format_large_number(coin_count)
	
		elif coin_count >= 1000:
			coin_count += randi_range(5000,8000)
			coin.text = "Coins: %s" % format_large_number(coin_count)
		
		elif coin_count >= 10000:
			coin_count += randi_range(9000,30000)
			coin.text = "Coins: %s" % format_large_number(coin_count)
			
		elif coin_count >= 100000:
			coin_count += randi_range(33333,99999)
			coin.text = "Coins: %s" % format_large_number(coin_count)
			
		else:
			coin_count += 1000
			coin.text = "Coins: %s" % format_large_number(coin_count)
		
		monster_death.play()
		monster_killed.play()
		enemy_random_spawn.position = Vector2(-1000,320) 
		health_bar.value = 5
		enemy_bite.wait_time = randi_range(5,7)
		

func _on_enemy_spawn_timer_timeout():
	var random_health = randi_range(5,10)
	health_bar.max_value = random_health
	health_bar.value = random_health
	
	print (random_health)
	
	monster_spawn.play()
	enemy_random_spawn.position = Vector2(randf_range(250,950),randf_range(300,400)) 
	
	health_bar.visible = true
	enemy_random_spawn.disabled = false
	enemy_bite.wait_time = randf_range(5,7)
	enemy_bite.start()
	

func _on_enemy_bite_timeout() -> void:
	var randomNumber = randi_range(1,4)
	var myCoinsNow = 0
	enemy_random_spawn.disabled = true
	health_bar.visible = false
	
	monster_bite.play()
	
	enemy_spawn_timer.wait_time = randf_range(25, 60)
	enemy_spawn_timer.start()
	
	print("BiteText Visible")
	bite_text.visible = true
	bite_text.rotation_degrees = randf_range(-15, 15)
	
	match randomNumber:
		1:
			bite_text.text = "BITTEN!"
		2:
			bite_text.text = "YEEEOWWWCH!"
		3:
			bite_text.text = "THAT HURT :("
		
	if  coin_count <= 1000:
		myCoinsNow += randi_range(500,780)
	
	elif coin_count >= 1000:
		myCoinsNow += randi_range(900,2000)
		
	elif coin_count >= 10000:
		myCoinsNow += randi_range(2000,9000)
		
	elif coin_count >= 100000:
		myCoinsNow += randi_range(10000,75000)
	
	elif coin_count > 1000000:
		myCoinsNow += randi_range(50000, 100000)
		
	else:
		myCoinsNow += randi_range(500,10000)
	
	print(myCoinsNow)
	if coin_count < myCoinsNow:
		coin_count = 0
	else:
		coin_count -= myCoinsNow
		
	amount_lost.text = "You lost %s coins!" % format_large_number(myCoinsNow)
	#amount_lost = some amount
	await get_tree().create_timer(3).timeout
	print("Untrue for timer now get out of here you prick")
	bite_text.visible = false
	bite_text.rotation = 0
	health_bar.value = 5


func _on_music_finished():
	var randomMusic = randi_range(1,5)
	
	match randomMusic:
		1:
			music.set_stream(MUSIC_1)
		2:
			music.set_stream(MUSIC_2)
		3:
			music.set_stream(MUSIC_3)
		4:
			music.set_stream(MUSIC_4)
		5:
			music.set_stream(MUSIC_5)
	
	music.playing = true
