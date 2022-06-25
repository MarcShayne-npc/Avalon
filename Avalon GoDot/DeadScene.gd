extends Control


var score = global.score
var score_file = "user://highscore2.txt"
var highscore = 0

func _ready():
	load_score()

func _process(delta):
	if int(score) > int(highscore):
		highscore = score
		save_score()
	score = str(score)
	$Panel/Label2.text = score
	if Input.is_action_just_pressed("z") or Input.is_action_just_pressed("x") or Input.is_action_just_pressed("c") or Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_up"):
		get_tree().change_scene("res://MainMenu.tscn")
	$Leaderboard/Label.text = str(highscore)


func load_score():
	var f = File.new()
	if f.file_exists(score_file):
		f.open(score_file, File.READ)
		var content = f.get_as_text()
		highscore = int(content)
		f.close()

# call this at game end to store a new highscore
func save_score():
	var f = File.new()
	f.open(score_file, File.WRITE)
	f.store_string(str(highscore))
	f.close()
