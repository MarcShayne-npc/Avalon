extends Area2D



func _on_BossRoom_body_entered(body):
	$AudioStreamPlayer.playing = false
	$AudioStreamPlayer2.playing = true
	pass # Replace with function body.


func _on_BossRoom_body_exited(body):
	$AudioStreamPlayer.playing = true
	$AudioStreamPlayer2.playing = false
	pass # Replace with function body.
