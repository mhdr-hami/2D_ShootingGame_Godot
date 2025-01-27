extends CharacterBody2D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/Player")
@onready var hud = get_node("/root/Main/Hud/EnemiesLabel")

var item_scene := preload("res://scenes/item.tscn")
var explosion_scene := preload("res://scenes/explosion.tscn")

signal hit_player

var alive : bool
var entered: bool
var speed: float = 150
var direction : Vector2
const DROP_CHANCE : float = 0.3
var wave : int = 1

func _ready() -> void:
	var screen_rect = get_viewport_rect()
	alive = true
	entered = false
	if main.wave == wave + main.boss_wave_number:
		speed *= main.DIFF_MULTIPLIER
		wave = main.wave
	#pick a direction for the enterance
	var dist = screen_rect.get_center() - position
	#check if need to move in x axis or y axis
	if abs(dist.x) > abs(dist.y):
		direction.x = dist.x
		direction.y = 0
	else:
		direction.y = dist.y
		direction.x = 0

func _physics_process(_delta: float) -> void:
	if alive:
		$AnimatedSprite2D.animation = "run"
		if entered:
			direction = (player.position - position)
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
	
		if velocity.x != 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		pass
		 
func die():
	alive = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.animation = "dead"
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	if randf() <= DROP_CHANCE:
		drop_item()
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	main.add_child(explosion)
	explosion.process_mode = Node.PROCESS_MODE_ALWAYS
	var enemies = get_tree().get_nodes_in_group("enemies")
	var num_dead_enemies = 0
	for e in enemies:
		if !e.alive:
			num_dead_enemies += 1
	hud.text = "X "+ str(main.max_enemies - num_dead_enemies)
	
	
func drop_item():
	var item = item_scene.instantiate()
	item.position = position
	item.item_type = randi_range(0, 2)
	main.call_deferred("add_child", item)
	item.add_to_group("items")
	
func _on_enterance_timer_timeout() -> void:
	entered = true
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	hit_player.emit()
