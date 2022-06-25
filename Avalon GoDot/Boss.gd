extends KinematicBody2D

onready var burnSpeed = 75
onready var normSpeed = 150
onready var SPEED = normSpeed
const GRAVITY = 10
const FLOOR = Vector2(0,-1)
onready var player = get_parent().get_parent().get_node("Player")
onready var velocity = Vector2()
onready var direction = 1
onready var burning = false
onready var playerDetected = false
onready var attacking = false
signal attack_signal(value)
onready var beam = false
onready var wave = false
onready var dying = false
onready var chasing = false

#chaseVariables
onready var react_time = 450
onready var direc = 0
onready var next_direc = 0
onready var next_direc_time = 0
const TARGET_PLAYER_DIST = 0

onready var next_jump_time = -1

# warning-ignore:unused_argument
func _physics_process(delta):
	
	
	if dying == true:
		effectsAnim.play("dying")
		if $AnimatedSprite.modulate.a <= 0:
			get_tree().change_scene("res://GameWin.tscn")
	
	if attacking == true and $AnimatedSprite.animation == "Attacking" and $AnimatedSprite.frame == 5 and dying == false:
		emit_signal("attack_signal", 15)
	
	#NOPLAYERCHASE
	if playerDetected == false and dying == false:
		$AnimatedSprite.animation = "Walking"
		velocity.y += GRAVITY
		
		if velocity.x > 0:
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
		
		velocity = move_and_slide(velocity,FLOOR)
		
		if is_on_wall():
			direction = direction *-1 
			$RayCast2D.position.x *= -1
		
		if $RayCast2D.is_colliding() == false:
			direction = direction *-1
			$RayCast2D.position.x *= -1
	
	#PLAYERCHASE
	elif playerDetected == true and dying == false :
		velocity.y += GRAVITY
		
		if player.position.x < (position.x - TARGET_PLAYER_DIST):
			$AnimatedSprite.flip_h = true
			set_direction(-1)
			if attacking == false:
				$AnimatedSprite.animation = "Walking"
			
			
		elif player.position.x > (position.x + TARGET_PLAYER_DIST):
			$AnimatedSprite.flip_h = false
			set_direction(1)
			if attacking == false:
				$AnimatedSprite.animation = "Walking"
				
		else:
			set_direction(0)
			if attacking == false:
				$AnimatedSprite.animation = "Idle"
		
		if OS.get_ticks_msec() > next_direc_time:
			direc = next_direc
		
		if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
			if player.position.y < position.y - 64:
				velocity.y = -400
			next_jump_time = -1
		
		if player.position.y < position.y - 64 and next_jump_time == -1:
			next_jump_time = OS.get_ticks_msec() + react_time
		
		velocity.x = SPEED * direc
		velocity = move_and_slide(velocity,FLOOR)
	
	
	#DAMAGE
	if burning == true and dying == false:
		if wave == true:
			damage(20)
		elif beam == true:
			damage(100)
		effectsAnim.play("Damaged")
		SPEED = burnSpeed
	else:
		if dying == false:
			effectsAnim.play("reset")
			SPEED = normSpeed


#Refactor some movement codes for player chase
func set_direction(target_direc):
	if next_direc != target_direc:
		next_direc = target_direc
		next_direc_time = OS.get_ticks_msec() + react_time



#HEALTH-----------------------------------------#
signal health_updated
var enemyMaxHealth = 1000
onready var enemyHealth = enemyMaxHealth setget _setEnemyHealth
onready var invulnerable = $InvulnerabilityTimer
onready var effectsAnim = $AnimationPlayer

func damage(amount):
	if invulnerable.is_stopped():
		invulnerable.start()
		_setEnemyHealth(enemyHealth - amount)
		effectsAnim.play("flash")

func kill():
	dying = true

func _setEnemyHealth(value):
	var prevEnemyHealth = enemyHealth
	enemyHealth = clamp(value, 0, enemyMaxHealth)
	if enemyHealth != prevEnemyHealth:
		emit_signal("health_updated")
	if enemyHealth == 0:
		kill()

func _on_InvulnerabilityTimer_timeout():
	effectsAnim.play("reset")
	pass # Replace with function body.



func _on_PlayerDetection_body_entered(body):
	playerDetected = true
	pass # Replace with function body.


func _on_PlayerDetection_body_exited(body):
	playerDetected = false
	pass # Replace with function body.


func _on_AttackZone_body_entered(body):
	$AnimatedSprite.animation = "Attacking"
	attacking = true
	pass # Replace with function body.

func _on_AttackZone_body_exited(body):
	attacking = false
	pass # Replace with function body.


func _on_HurtBox_area_entered(area):
	if "Wave" in area.name:
		wave = true
		beam = false
	elif "Beam" in area.name:
		beam = true
		wave = false
	burning = true
	pass # Replace with function body.


func _on_HurtBox_area_exited(area):
	burning = false
	SPEED = normSpeed
	pass # Replace with function body.



func _on_AntiStuck_area_entered(area):
	velocity.y = -100
	pass # Replace with function body.

#SOUND---------------------------------------#

func _process(delta):
	if $AnimatedSprite.animation == ("Attacking") and $AnimatedSprite.frame == 5:
		if $Smash.playing == false:
			$Smash.playing = true