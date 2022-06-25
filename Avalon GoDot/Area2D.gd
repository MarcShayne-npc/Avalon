extends Area2D



onready var pPos = get_parent().get_node("KinematicBody2D")
onready var pMotion = pPos.motion
onready var ePos = $Sprite.position
var inside = false

func _physics_process(delta):
	if inside == true:
		self.position.x = lerp(self.position.x, pPos.position.x, 0.2)
	pass


func _on_Area2D_body_exited(body):
	$Sprite.position = ePos
	inside = false
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	inside = true
