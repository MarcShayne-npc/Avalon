extends Area2D

export (int) var speed
export (int) var damage

var velocity = Vector2()

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed
	

func _process(delta):
	position += velocity * delta



func _on_Bullet_body_entered(body):
	queue_free()
	if body.has_method("damage"):
		body.damage(damage)
	pass # Replace with function body.
