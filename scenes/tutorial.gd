extends Node2D

@export var strings: Array[String] = []
@export var player: Player
var current_step = 0
@export var label: Label
@export var trans: Transition

var use_mage_action1 := false
var use_mage_action2 := false
var finishing := false


func _ready() -> void:
	player.get_node("Parry").bullets_parried.connect(_on_bullets_parried)


func _on_bullets_parried(count: int) -> void:
	if current_step == 3 and count > 0:
		current_step = 4
		#if is_instance_valid(ghost_ref):
			#queue_free()
		next_step()
		ghost_ref.hc.health = 1


func update_label(step):
	if step < len(strings):
		label.text = _wrap_every(strings[step], 50)


func _wrap_every(text: String, limit: int) -> String:
	var remaining := text
	var lines: PackedStringArray = []
	while remaining.length() > limit:
		var break_at := remaining.rfind(" ", limit)
		if break_at > 0:
			lines.append(remaining.substr(0, break_at))
			remaining = remaining.substr(break_at + 1)
		else:
			lines.append(remaining.substr(0, limit))
			remaining = remaining.substr(limit)
	if remaining.length() > 0:
		lines.append(remaining)
	return "\n".join(lines)
		
#Index 0 - move to point
#index 1 - fire weapon. everything costs score or gives score
#index 2 - kill zombie, wolf hands drain score over time
#index 3 - unkillable, 0 speed ghost. parry it
#index 4 - kill the ghost
#index 5 - switch weapon
#index 6 - use both mage attacks, then start the game


var zombie = preload("res://enemies/zombie/zombie.tscn")
var z_ref: Zombie
var spawned_zombie = false
func spawn_zombie() -> void:
	var z = zombie.instantiate()
	z.global_position = Vector2(500, 0)
	get_tree().root.add_child(z)
	spawned_zombie = true
	z_ref = z

var ghost = preload("res://enemies/bat/bat.tscn")
var ghost_ref: Bat
var spawned_ghost = false
func spawn_ghost() -> void:
	var z = ghost.instantiate()
	z.global_position = Vector2(300, -300)
	get_tree().root.add_child(z)
	spawned_ghost = true
	ghost_ref = z


func next_step():
	update_label(current_step)
	if current_step == 1:
		pass
	if current_step == 2:
		spawn_zombie()
	if current_step == 3:
		spawn_ghost()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action1") and current_step == 1:
		current_step = 2
		next_step()
	
	#Check if we successfully parry 
	
	if Input.is_action_just_pressed("go_sharp") and current_step == 5:
		current_step = 6
		next_step()
		
	if current_step == 2 and spawned_zombie:
		if !is_instance_valid(z_ref):
			current_step = 3
			next_step()
	if current_step == 4 and spawned_ghost:
		if !is_instance_valid(ghost_ref):
			current_step = 5
			next_step()
	
	if current_step == 6 and not finishing:
		if player.hand_state == player.Hands.Mage:
			if Input.is_action_just_pressed("action1"):
				use_mage_action1 = true
			if Input.is_action_just_pressed("action2"):
				use_mage_action2 = true
		if use_mage_action1 and use_mage_action2:
			finishing = true
			_finish_tutorial()


func _finish_tutorial() -> void:
	await get_tree().create_timer(1.0).timeout
	trans.fade_start()


func _on_move_point_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and current_step == 0:
		current_step = 1
		next_step()
		$MovePoint.visible = false
