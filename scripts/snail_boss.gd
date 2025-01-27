extends CharacterBody2D

@onready var main = get_node("/root/Main")
@onready var player = get_node("/root/Main/Player")

var explosion_scene := preload("res://scenes/explosion.tscn")

signal hit_player

var alive : bool
var entered: bool
var direction : Vector2
var speed: float = 180
var HP : float = 100
var level : int = 1

func _ready() -> void:
	var screen_rect = get_viewport_rect()
	HP = main.snail_boss_HP
	if main.boss_number > level:
		level = main.boss_number
		speed *= 1.2
	$HP_Label.text = str(int(HP))
	alive = true
	entered = false
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
		$AnimatedSprite2D.animation = "walk"
		if entered:
			direction = (player.position - position)
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
		if velocity.x != 0:
			$AnimatedSprite2D.flip_h = velocity.x > 0
	else:
		pass
		 
func die():
	alive = false
	$HP_Label.hide()
	$AnimatedSprite2D.animation = "dead"
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	main.add_child(explosion)
	explosion.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_enterance_timer_timeout() -> void:
	entered = true
	
func _on_area_2d_body_entered(_body: Node2D) -> void:
	hit_player.emit()

func got_shot():
	HP = main.snail_boss_HP
	$HP_Label.text = str(int(HP))
