extends Node2D

@export var bullet_scene : PackedScene

signal hit_b

func _on_player_shoot(pos, dir) -> void:
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.position = pos
	bullet.direction = dir.normalized()
	bullet.add_to_group("bullets")
	bullet.hit_boss.connect(hitBoss)
	
func hitBoss():
	hit_b.emit()
