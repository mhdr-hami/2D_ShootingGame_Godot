extends Node

var heart_card_scene := preload("res://scenes/heart_card.tscn")
var gun_card_scene := preload("res://scenes/gun_card.tscn")
var lightning_scene := preload("res://scenes/lightning.tscn")

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/Player")

const DIFF_MULTIPLIER : float = 1.2
const CARD_CHANCE : float = 1
const SUPER_KILL_TIME : float = 1.0
var wave : int
var difficulty : float
var max_enemies : int
var lives : int
var supers : int
var heart_card_value : int
var card_value : float
var boss_mode : bool = false
var snail_boss_HP : float = 100.0
var snail_boss_bullet_damage : float = 5.0
var boss_wave_number : int = 3
var boss_number : int = 1

func _ready() -> void:
	new_game()
	$GameOver/Button.pressed.connect(new_game)
	$HeartCard/Button.pressed.connect(heart_card_chosen)
	$GunCard/Button.pressed.connect(gun_card_chosen)
	#$SuperCard/Button.pressed.connect(super_card_chosen)
	$SuperCard/Button.pressed.connect(super_card_chosen)
	$GunCard/Button.pressed.connect(player.update_player_after_cards)
	
func new_game():
	lives = 3
	supers = 0
	wave = 1
	difficulty = 10.0
	heart_card_value = 2
	card_value = 0
	boss_mode = false
	snail_boss_HP = 100.0
	snail_boss_bullet_damage = 5.0
	boss_number = 1
	$EnemySpawner/Timer.wait_time = 1.0
	reset()

func reset(): 
	max_enemies = int(difficulty)
	$Player.reset()
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	get_tree().call_group("items", "queue_free")
	get_tree().call_group("bosses", "queue_free")
	$Hud/LivesLabel.text = "X "+ str(lives)
	$Hud/EnemiesLabel.text = "X "+ str(max_enemies)
	$Hud/SuperLabel.text = "X "+ str(supers)
	$Hud/EnemiesLabel.hide()
	$GameOver.hide()
	$HeartCard.hide()
	$GunCard.hide()
	#$SuperCard.hide()
	$SuperCard.hide()
	$Xmark.hide()
	get_tree().paused = true
	$RestartTimer.start()
	$BossSpawner/Timer.paused = true
	$BossRestartTimer.paused = true
	$EnemySpawner/Timer.paused = false
	
func _process(_delta: float) -> void:
	if !boss_mode:
		$Hud/EnemiesLabel.show()
		$Hud/WaveLabel.text = "WAVE: "+ str(wave)
		$Hud/EnemySprite.show()
		$Hud/SnailBossSprite.hide()
		
		if Input.is_action_pressed("superPower") and supers>0:
			supers -= 1
			$Hud/SuperLabel.text = "X "+str(supers)
			var enemies = get_tree().get_nodes_in_group("enemies")
			var num_alive_enemies = 0
			for e in enemies:
				if e.alive:
					num_alive_enemies+=1
			$SuperPowerTimer.wait_time = SUPER_KILL_TIME/num_alive_enemies
			$SuperPowerTimer.start()
			print("super power used!!")
			
		if is_wave_completed():
			wave += 1
			#adjast difficulty
			difficulty *= DIFF_MULTIPLIER * (1 + card_value/10)
			if $EnemySpawner/Timer.wait_time > 0.25:
				$EnemySpawner/Timer.wait_time -= 0.05
			
			####
			get_tree().paused = true
			#randomly show random carts
			if !drop_cards():
				$WaveOverTimes.start()
			if wave % boss_wave_number == 0:
				boss_mode = true
	elif boss_mode:
		$Hud/WaveLabel.text = "BOSS MODE"
		$Hud/EnemiesLabel.text = "Snail"
		$Hud/EnemiesLabel.show()
		$Hud/EnemySprite.hide()
		$Hud/SnailBossSprite.show()
		$EnemySpawner/Timer.paused = true
		$BossSpawner/Timer.paused = false
		#print($BossSpawner/Timer.time_left)
		if is_boss_level_completed():
			$BossRestartTimer.paused = false
			snail_boss_HP = 100
			
func drop_cards():
	if randf() <= CARD_CHANCE:
		var rand_num = randi()%2
		$HeartCard/CardTypeLabel.text = "+" + str(heart_card_value)
		$GunCard/CardTypeLabel.text = "+" + str((1.3-1)*100) + "%"
		if rand_num==0:
			$HeartCard.show()
			$GunCard.show()
		#elif rand_num==5:
			#$HeartCard/CardTypeLabel.text = "+" + str(heart_card_value)
			##$HeartCard.position = screen_size / 2
			#$HeartCard.show()
			#$SuperCard.show()
		else:
			$SuperCard.show()
			$GunCard.show()
		
		return true
	return false

func heart_card_chosen():
	lives += heart_card_value
	#$WaveOverTimes.start()
	card_value += 1
	reset()

func gun_card_chosen():
	#$WaveOverTimes.start()
	card_value += 1
	reset()

func super_card_chosen():
	supers += 1
	#$WaveOverTimes.start()
	card_value += 1
	reset()
	
func _on_enemy_spawner_hit_p() -> void:
	$Xmark.position = player.position
	$Xmark.show()
	lives -= 1
	$Hud/LivesLabel.text = "X "+ str(lives)
	get_tree().paused = true
	if lives <= 0:
		$GameOver/WavesSurvivedLabel.text = "WAVES SURVIVED: " + str(wave - 1)
		$GameOver.show()
	else:
		$WaveOverTimes.start()
		
func _on_wave_over_times_timeout() -> void:
	reset() 

func _on_restart_timer_timeout() -> void:
	get_tree().paused = false

func is_wave_completed():
	var all_dead = true
	var enemies = get_tree().get_nodes_in_group("enemies")
	#check if all enemies have spawned left
	if enemies.size() == max_enemies:
		for e in enemies:
			if e.alive:
				all_dead = false
		return all_dead
	else: 
		return false

func is_boss_level_completed():
	var all_dead = true
	var bosses = get_tree().get_nodes_in_group("bosses")
	#check if all bosses have spawned left
	if bosses.size() == 1:
		for b in bosses:
			if b.alive:
				all_dead = false
		return all_dead
	else: 
		return false

func _on_boss_restart_timer_timeout() -> void:
	get_tree().call_group("bosses", "queue_free")
	boss_mode = false
	wave+=1
	reset()

func _on_boss_spawner_hit_p() -> void:
	lives -= 1
	$Hud/LivesLabel.text = "X "+ str(lives)
	$Xmark.position = player.position
	$Xmark.show()
	get_tree().paused = true
	if lives <= 0:
		$GameOver/WavesSurvivedLabel.text = "WAVES SURVIVED: " + str(wave - 1)
		$GameOver.show()
	else:
		$WaveOverTimes.start()

func _on_bullet_manager_hit_b() -> void:
	var bosses = get_tree().get_nodes_in_group("bosses")
	snail_boss_HP -= snail_boss_bullet_damage
	bosses[0].got_shot()
	if bosses[0].HP <= 0:
		bosses[0].alive = false
		bosses[0].die()
		snail_boss_bullet_damage *= 0.5
		boss_number += 1

func _on_super_power_timer_timeout() -> void:
	get_tree().call_group("lights", "queue_free")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.alive:
			e.die()
			var light = lightning_scene.instantiate()
			light.position = e.position
			light.add_to_group("lights")
			main.call_deferred("add_child", light)
			#main.add_child(light)
			$SuperPowerTimer.start()
			break
	
