extends Node

onready var allEnemies = []
signal enemy_attacking
var enemy = "Enemy"
var c = 0
func _ready():
	allEnemies = get_children()
	for i in allEnemies:
		c += 1
		get_node(enemy+str(c)).connect("attack_signal", self, "enemyAttack")

func enemyAttack(amount):
	emit_signal("enemy_attacking", amount) 