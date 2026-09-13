extends Control

@onready var time_label = %Time
@onready var score_label = %Score

@export var gs: GameState
@export var sm: ScoreManager

@onready var blood = %BloodIcon
var blood_tween: Tween
var scale_debt := 0.0

const BLOOD_DEBT_PER_HIT := 0.45
const BLOOD_DEBT_MAX := 2.4
const BLOOD_SETTLE_TIME := 1.0

func _ready() -> void:
	#Connect to signal from scoremanager to tween blood
	sm.score_changed.connect(tween_blood)

#Tween Scale Punch with rotation
func tween_blood() -> void:
	scale_debt = minf(maxf(scale_debt, 0.0) + BLOOD_DEBT_PER_HIT, BLOOD_DEBT_MAX)
	_apply_blood_debt(scale_debt)
	blood.offset_transform_rotation = deg_to_rad(randf_range(-12.0, 12.0) * (1.0 + scale_debt))
	if blood_tween and blood_tween.is_valid():
		blood_tween.kill()
	blood_tween = create_tween().set_parallel()
	blood_tween.tween_method(_consume_scale_debt, scale_debt, 0.0, BLOOD_SETTLE_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	blood_tween.tween_property(blood, "offset_transform_rotation", 0.0, BLOOD_SETTLE_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _consume_scale_debt(remaining: float) -> void:
	scale_debt = remaining
	_apply_blood_debt(remaining)

func _apply_blood_debt(debt: float) -> void:
	var s := maxf(1.0 + debt, 0.7)
	blood.offset_transform_scale = Vector2(s, s)

func _process(delta: float) -> void:
	if gs.round_timer:
		time_label.text = str(gs.round_timer.time_left).left(5)
		
	if sm.score:
		score_label.text = str(int(sm.score))
