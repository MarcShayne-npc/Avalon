extends Node

func _process(delta):
	global.score = $Player.score

func _on_FlyingMobs_shoot(bullet, _position, _direction):
	var b = bullet.instance()
	add_child(b)
	b.start(_position, _direction)
	pass # Replace with function body.








