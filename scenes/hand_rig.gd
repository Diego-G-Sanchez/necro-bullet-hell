extends Node2D

#Capture the player's input and 
#activate ability 1 or 2. 
#Can code wolf ability

#Hand State lives on the player
@export var player: Player
@onready var meleeHB: HitBox = %MeleeHitBox
@export var parry_anim: AnimationPlayer


var bulletSharp = preload("res://scenes/playerbullet.tscn")
var bulletFrost = preload("res://scenes/frost.tscn")
var bulletFireball = preload("res://scenes/fire_ball.tscn")


signal dash_used

const WOLF_SLASH_SFX := preload("res://sounds/sfx/wolfattack.wav")
const WOLF_PARRY_SFX := preload("res://sounds/sfx/parry2.wav")


func _process(_delta: float) -> void:
	if Input.is_action_pressed("action1"):
		match player.hand_state:
			player.Hands.Wolf:
				wolf_slash()
			player.Hands.Shooter:
				sharp_shoot()
			player.Hands.Mage:
				mage_frost()

	if Input.is_action_pressed("action2"):
		match player.hand_state:
			player.Hands.Wolf:
				wolf_parry()
			player.Hands.Shooter:
				sharp_dash()
			player.Hands.Mage:
				mage_fire_bomb()
	
	if Input.is_action_just_pressed("go_wolf") and player.hand_state != player.Hands.Wolf:
		switch_to_wolf()
		
	if Input.is_action_just_pressed("go_sharp") and player.hand_state != player.Hands.Shooter:
		switch_to_sharp()

	if Input.is_action_just_pressed("go_mage") and player.hand_state != player.Hands.Mage:
		switch_to_mage()
	
	
var hswp := preload("res://scenes/hand_swap_particle.tscn")
var sacrifice_sound = preload("res://sounds/sfx/sacrifice.wav")
func play_weapon_switch():
	var p = hswp.instantiate()
	p.global_position = global_position
	get_tree().root.add_child(p)
	Sfx.play(sacrifice_sound)
	
func switch_to_wolf():
	play_weapon_switch()
	player.sm.change_score(-player.sm.config.wolf_swap_cost, global_position)
	player.hand_state = player.Hands.Wolf
	$HandL.texture = preload("res://assets/hand_l_werewolf.png")
	$HandR.texture = preload("res://assets/hand_r_werewolf.png")
	
func switch_to_sharp():
	play_weapon_switch()
	player.sm.change_score(-player.sm.config.sharp_swap_cost, global_position)
	player.hand_state = player.Hands.Shooter
	$HandL.texture = preload("res://assets/hand_l_sharp.png")
	$HandR.texture = preload("res://assets/hand_l_sharp.png")

func switch_to_mage():
	play_weapon_switch()
	player.sm.change_score(-player.sm.config.mage_swap_cost, global_position)
	player.hand_state = player.Hands.Mage
	$HandL.texture = preload("res://assets/hand_l_mage.png")
	$HandR.texture = preload("res://assets/hand_r_mage.png")
	
func wolf_slash():
	if player.wolf_claw_cd <= 0.0:
		$AnimationPlayer.play("wolf_slash_2")
		Sfx.play(WOLF_SLASH_SFX, global_position)
		player.sm.change_score(-player.sm.config.slash_cost, global_position)
		#Configure hitbox damage
		meleeHB.set_damage(player.sm.config.slash_damage)
		player.wolf_claw_cd = player.sm.config.wolf_claw_cd
	
func wolf_parry():
	if player.wolf_parry_cd <= 0.0:
		Sfx.play(WOLF_PARRY_SFX, global_position)
		parry_anim.play("Parry")
		player.sm.change_score(-player.sm.config.parry_cost, global_position)
		player.wolf_parry_cd = player.sm.config.wolf_parry_cd

func sharp_shoot():
	if player.sharp_shoot_cd <= 0.0:
		Sfx.play(preload("res://sounds/sfx/shootGun0.wav"))
		shoot(bulletSharp)
		player.sm.change_score(-player.sm.config.shot_cost, global_position)
		player.sharp_shoot_cd = player.sm.config.sharp_shoot_cd

func sharp_dash():
	if player.sharp_dash_cd <= 0.0:
		Sfx.play(preload("res://sounds/sfx/dash.wav"))
		player.dash.dash()
		dash_used.emit()
		player.sm.change_score(-player.sm.config.dash_cost, global_position)
		player.sharp_dash_cd = player.sm.config.sharp_dash_cd

func mage_frost():
	if player.mage_frost_cd <= 0.0:
		$AnimationPlayer.play("mage_frost_cast")
		shoot(bulletFrost)
		player.sm.change_score(-player.sm.config.frost_cost, global_position)
		player.mage_frost_cd = player.sm.config.mage_frost_cd

func mage_fire_bomb():

	if player.mage_fireball_cd <= 0.0:
		$AnimationPlayer.play("mage_fireball_cast")
		shoot(bulletFireball)
		player.sm.change_score(-player.sm.config.fire_ball_cost, global_position)
		player.mage_fireball_cd = player.sm.config.mage_fireball_cd

func _emit_frost_shards() -> void:
	$FrostShards.restart()

func _emit_fire_embers() -> void:
	$FireEmbers.restart()


func shoot(bullet: PackedScene):
	var b = bullet.instantiate()
	b.global_position = global_position
	b.initialize(player.sm.config)

	b.dir = (get_global_mouse_position() - player.global_position).normalized()
	get_tree().root.add_child(b)

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "wolf_slash_2":
		$MeleeHitBox/CollisionShape2D.disabled = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "wolf_slash_2":
		$MeleeHitBox/CollisionShape2D.disabled = true
