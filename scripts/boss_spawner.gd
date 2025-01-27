extends Node2D

@onready var main = get_node("/root/Main")

signal hit_p

var snail_boss_scene := preload("res://scenes/snail_boss.tscn")
var spawn_points := []

func _ready() -> void:
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)
			
func _on_timer_timeout() -> void:
	#print("entered timer time out")
	var bosses = get_tree().get_nodes_in_group("bosses")
	if bosses.size() < 1:
		#print("must show the boss")
		#pick random spwan point
		var spawn = spawn_points[randi() % spawn_points.size()]
		#spawn boss
		var snail_boss = snail_boss_scene.instantiate()
		snail_boss.position = spawn.position
		snail_boss.hit_player.connect(hit)
		main.add_child(snail_boss)
		snail_boss.add_to_group("bosses")
		snail_boss.show()

func hit():
	hit_p.emit()
