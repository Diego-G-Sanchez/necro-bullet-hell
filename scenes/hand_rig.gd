extends Node2D

#Capture the player's input and 
#activate ability 1 or 2. 
#Can code wolf ability

#Hand State lives on the player
@export var player: Player

signal dash_used

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action1"):
		match player.hand_state:
			player.Hands.Wolf:
				wolf_slash()
			player.Hands.Shooter:
				sharp_shoot()
			player.Hands.Mage:
				mage_frost()

	if Input.is_action_just_pressed("action2"):
		match player.hand_state:
			player.Hands.Wolf:
				wolf_parry()
			player.Hands.Shooter:
				sharp_dash()
			player.Hands.Mage:
				mage_fire_bomb()
				
func wolf_slash():
	pass
func wolf_parry():
	pass
	
func sharp_shoot():
	pass
func sharp_dash():
	#emit signal so parent can run dash physics on player
	pass

func mage_frost():
	pass
func mage_fire_bomb():
	pass
