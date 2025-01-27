extends Area2D

var speed : int = 500
var direction : Vector2

signal hit_boss

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += speed * direction * delta

func _on_timer_timeout() -> void:
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "World":
		queue_free()
	else:
		if body.name.begins_with("Goblin") and body.alive:
			body.die()
			queue_free()
		elif body.name == "SnailBoss" and body.alive:
			hit_boss.emit()
			queue_free()
			
		#then this is the enemy
		#if body.alive:
			#body.die()
			#queue_free()
			
