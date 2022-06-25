extends Control

var score = global.score

func _process(delta):
	if Input.is_action_just_pressed("z") or Input.is_action_just_pressed("x") or Input.is_action_just_pressed("c") or Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://DeadScene.tscn")
