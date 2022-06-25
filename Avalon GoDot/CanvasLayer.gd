extends CanvasLayer

onready var hpLabel = $Interface/HPHere
onready var energyLabel = $Interface/EnHere
onready var scoreLabel = $Interface/ScoreHere


func _process(delta):
	var energy = get_parent().get_node("Player").energy
	var health = get_parent().get_node("Player").health
	var score = get_parent().get_node("Player").score
	var entext = str(int(energy))
	var hptext = str(int(health))
	var sctext = str(int(score))
	hpLabel.text = hptext
	energyLabel.text = entext
	scoreLabel.text = sctext