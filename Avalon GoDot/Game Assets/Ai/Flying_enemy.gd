extends KinematicBody2D

const GRAVITY = 100
const FLOOR = Vector2(0,-1)

var velocity = Vector2()
var direction = 1

# warning-ignore:unused_argument
func _physics_process(delta):
	velocity.y = GRAVITY * direction
	velocity.x = 0
	velocity = move_and_slide(velocity,FLOOR)
	
	if is_on_floor():
		direction = direction *-1 
	elif is_on_ceiling():
		direction = direction * -1
