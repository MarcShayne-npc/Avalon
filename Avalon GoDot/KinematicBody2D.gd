extends KinematicBody2D

var doublesound = false
        #MOVEMENT#
#-------------------------------#
var motion = Vector2()
const ACCEL = 10
var GRAVITY = 10
const MAXSPEED = 150
const UP = Vector2(0, -1)
var JUMP = -285
#value from 0-1
const FRICTION_FLOOR = 0.15
const FRICTION_AIR = 0.05
const DASHTIME = 0.25
const DASHSPEED = 650
var dashing = false
var dash_acc = 0
var dash_cooldown = 0
const CDADD = 20
const CDDEC = 0.5
var double_jump = false
var shooting = false
var aniFinish = false
var dead = false
var beaming = false
var is_on_Trap = false
var invul = false
var gaining_Energy = false
var enemies = 0

func _ready():
	get_parent().get_node("Enemies").connect("enemy_attacking", self, "damage")
	$AnimationPlayer.play("rest")



func _physics_process(delta):
	if dead == true:
		$AnimationPlayer.play("dying")
		if $Light2D.energy > 1.5:
			get_tree().change_scene("res://DeadScene.tscn")
	if dashing:
		motion.y = 0
	motion.y += GRAVITY
	var friction_state = false
	if dashing == false and shooting == false and dead == false:
		aniFinish = false
		if Input.is_action_pressed("ui_right"):
			if dash_cooldown <= 0:
					dash_cooldown = 0
			else:
				dash_cooldown -= CDDEC
			motion.x = min(motion.x+ACCEL, MAXSPEED)
			$Sprite.flip_h = false
			if is_on_floor():
				if $Sprite.animation != "Dash":
					$Sprite.animation = "Run"
		
		elif Input.is_action_pressed("ui_left"):
			if dash_cooldown <= 0:
				dash_cooldown = 0
			else:
				dash_cooldown -= CDDEC
			motion.x = max(motion.x-ACCEL, -MAXSPEED)
			$Sprite.flip_h = true
			if is_on_floor():
				if $Sprite.animation != "Dash":
					$Sprite.animation = "Run"
		else:
			if is_on_floor():
				if dash_cooldown <= 0:
					dash_cooldown = 0
				else:
					dash_cooldown -= CDDEC
				if $Sprite.animation != "Dash" and $Sprite.animation != "Attack_End":
					$Sprite.animation = "Idle"
				friction_state = true
				if friction_state == true:
					  motion.x = lerp(motion.x, 0, FRICTION_FLOOR)
	
	
	
		if is_on_floor():
			if Input.is_action_pressed("ui_up"):
				motion.y = JUMP
			double_jump = false
		else:
			friction_state = true
			if friction_state == true:
				motion.x = lerp(motion.x, 0, FRICTION_AIR)
				$Sprite.animation = "Jump"
			if Input.is_action_just_pressed("ui_up") && double_jump == false:
				motion.y = JUMP
				double_jump = true
			if dash_cooldown <= 0:
				dash_cooldown = 0
			else:
				dash_cooldown -= CDDEC
			
	
	if shooting == true:
		motion.x = lerp(motion.x, 0, 0.4)
	
	if shooting == false and dead == false and beaming == false:
		if Input.is_action_just_pressed("ui_select"):
			invulnerable()
			if dash_cooldown <= 0:
				dashing = true
				if $Sprite.flip_h == false:
					motion.x = DASHSPEED
				else:
					motion.x = -DASHSPEED
	
	if dashing == false and is_on_floor() and dead == false:
		if Input.is_action_just_pressed("x") and beaming == false and !Input.is_action_pressed("ui_up") and shooting == false and energy >= 50:
			useEnergy(50)
			shooting = true
			beaming = true
			$Sprite.animation = "Attack_Start"
			$Position2D5/Beam/BeamSprite.frame = 1
			$Position2D6/Beam/BeamSprite.frame = 1
		elif Input.is_action_pressed("z") and beaming == false:
			shooting = true
			$Sprite.animation = "Attack_Start"
			if aniFinish == true and Input.is_action_pressed("ui_up"):
				$Sprite.animation = "Diagonal"
				$Position2D.visible = false
				$Position2D2.visible = false
				if $Sprite.flip_h == false:
					$Position2D3.visible = true
					$Position2D3/Wave/CollisionPolygon2D.disabled = false
				elif $Sprite.flip_h == true:
					$Position2D4.visible = true
					$Position2D4/Wave/CollisionPolygon2D.disabled = false
			elif Input.is_action_just_released("ui_up"):
				$Sprite.frame = 23
				$Position2D3.visible = false
				$Position2D3/Wave/CollisionPolygon2D.disabled = true
				$Position2D4.visible = false
				$Position2D4/Wave/CollisionPolygon2D.disabled = true
		elif Input.is_action_just_released("z"):
			if beaming == false:
				if aniFinish == true:
					aniFinish = false
					$Sprite.animation = "Attack_End"
				else:
					$Sprite.animation = "Attack_Start"
	
	
	if aniFinish == false:
		$Position2D.visible = false
		$Position2D2.visible = false
		$Position2D3.visible = false
		$Position2D4.visible = false
		$Position2D/Wave/CollisionPolygon2D.disabled = true
		$Position2D2/Wave/CollisionPolygon2D.disabled = true
		$Position2D3/Wave/CollisionPolygon2D.disabled = true
		$Position2D4/Wave/CollisionPolygon2D.disabled = true
	
	if dashing and dead == false:
		dash_acc += delta
		$Sprite.animation = "Dash"
		if dash_acc >= DASHTIME:
			dash_cooldown += CDADD
			dashing = false
			motion.x = lerp(motion.x, 0, 0.8)
			dash_acc = 0
			$Sprite.animation = "Idle"
	
	if Input.is_action_pressed("c"):
		if energy >= 1 and health != max_health and shooting == false:
			useEnergy(1)
			heal(0.3)
	
	if $Position2D5/Beam/BeamSprite.frame >= 15 and beaming == true:
		$Position2D5/Beam/CollisionShape2D.disabled = false
	elif $Position2D6/Beam/BeamSprite.frame >= 15 and beaming == true:
		$Position2D6/Beam/CollisionShape2D.disabled = false
	
	if $Position2D5/Beam/BeamSprite.frame == 35 and beaming == true:
		$Position2D5/Beam/BeamSprite.playing = false
		$Position2D5.visible = false
		$Position2D5/Beam/CollisionShape2D.disabled = true
		$Sprite.animation = "Attack_End"
	elif $Position2D6/Beam/BeamSprite.frame == 35 and beaming == true:
		$Position2D6/Beam/BeamSprite.playing = false
		$Position2D6.visible = false
		$Position2D6/Beam/CollisionShape2D.disabled = true
		$Sprite.animation = "Attack_End"
	
	
	if is_on_Trap == true:
		damage(20)
	
	if invul == true:
		if invulnerability_Timer.is_stopped():
			invulnerability_Timer.wait_time = 0.35
			invulnerability_Timer.start()
			damage(0)
	
	if invul == false:
		invulnerability_Timer.wait_time = 1
	
	
	if gaining_Energy == true:
		for i in enemies:
			useEnergy(-0.3)
			score += 1
	
	motion = move_and_slide(motion, UP, true)


func _on_ghostTimer_timeout():
	if $Sprite.animation == "Dash":
		var this_Ghost = preload("res://Ghost.tscn").instance()
		get_parent().add_child(this_Ghost)
		this_Ghost.position = position
		this_Ghost.texture = $Sprite.frames.get_frame($Sprite.animation, $Sprite.frame)
		this_Ghost.flip_h = $Sprite.flip_h
	
#-----------------------------------------#

                #HEALTH#
#-----------------------------------------#
signal health_updated(health)
signal killed()

export (float) var max_health = 100
onready var health = max_health setget _set_health
onready var invulnerability_Timer = $InvulnerabilityTimer
onready var effects_Animations = $AnimationPlayer

func invulnerable():
	invul = true

func heal(amount):
	$AnimationPlayer.play("heal")
	_set_health(health + amount)

func damage(amount):
	if invulnerability_Timer.is_stopped():
		invulnerability_Timer.start()
		_set_health(health - amount)
		effects_Animations.play("Damage")
		effects_Animations.queue("flash")

func kill():
	dead = true

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if  health != prev_health:
		emit_signal("health_updated", health) 
		if health == 0:
			kill()

func debugHealth():
	if Input.is_action_just_pressed("ui_page_up"):
		damage(20)
	elif Input.is_action_just_pressed("ui_page_down"):
		damage(-20)


func _on_InvulnerabilityTimer_timeout():
	effects_Animations.play("rest")
	invul = false
	pass 
#----------------------------------------------#

#-----------------ENERGY-----------------------#

onready var maxEnergy = 99999
onready var energy = 100 setget _setEnergy


func useEnergy(value):
	_setEnergy(energy - value)

func _setEnergy(amount):
	energy = clamp(amount, 0, maxEnergy)

#----------------------------------------------#



                       #COMBAT#
#------------------------------------------------#


func _on_Sprite_animation_finished():
	if $Sprite.animation == "Attack_Start":
		aniFinish = true
		if beaming == true:
			if $Sprite.flip_h == false:
				$Position2D5/Beam/BeamSprite.playing = true
				$Position2D5/Beam/BeamSprite.frame = 1
				$Position2D5.visible = true
			else:
				$Position2D6/Beam/BeamSprite.frame = 1
				$Position2D6/Beam/BeamSprite.playing = true
				$Position2D6.visible = true
		if beaming == false:
			if $Sprite.flip_h == false and !Input.is_action_pressed("ui_up"):
				$Position2D.visible = true
				$Position2D/Wave/CollisionPolygon2D.disabled = false
			elif $Sprite.flip_h == true and !Input.is_action_pressed("ui_up"):
				$Position2D2.visible = true
				$Position2D2/Wave/CollisionPolygon2D.disabled = false
			if !Input.is_action_pressed("z"):
				$Sprite.animation = "Attack_End"
	if $Sprite.animation == "Attack_End":
		shooting = false
		beaming = false


func _on_Wave_body_entered(body):
	enemies += 1
	if enemies > 0:
		gaining_Energy = true
	pass # Replace with function body.


func _on_Wave_body_exited(body):
	enemies -= 1
	if enemies == 0:
		gaining_Energy = false
	pass # Replace with function body.

#SCORING#

var score = 0


func _on_HurtBox_area_entered(area):
	is_on_Trap = true
	pass # Replace with function body.


func _on_HurtBox_area_exited(area):
	is_on_Trap = false
	pass # Replace with function body.


	
#SOUNDS------------------------------------#
onready var HeatSound = $Audios/HeatWave
onready var BeamSound = $Audios/Beam
onready var Walk = $Audios/Walk

func _process(delta):
	if $Position2D.visible == true or $Position2D2.visible == true or $Position2D3.visible == true or $Position2D4.visible == true:
		if HeatSound.playing == false:
			HeatSound.playing = true
	else:
		HeatSound.playing = false
	
	if $Position2D5.visible == true or $Position2D6.visible == true:
		if BeamSound.playing == false:
			BeamSound.playing = true
	else:
		BeamSound.playing = false
	
	if $Sprite.animation == "Run":
		if Walk.playing == false:
			Walk.playing = true
	else:
		Walk.playing = false
	
	if $Sprite.animation == "Dash":
		if $Audios/Dash.playing == false:
			$Audios/Dash.playing = true
	
	if is_on_floor():
		doublesound = false
	print(doublesound)
	
	if $Sprite.animation == "Jump" and Input.is_action_just_pressed("ui_up") and doublesound == false:
		if $Audios/Jump.playing == false:
			$Audios/Jump.playing = true
			doublesound = true


func _on_Slide_body_entered(body):
	GRAVITY = 50
	JUMP = 0
	pass # Replace with function body.


func _on_Slide_body_exited(body):
	GRAVITY = 10
	JUMP = -285
	pass # Replace with function body.
