extends Resource
class_name ScoreConfig

@export var init_score: float = 2500.0

@export_group("Vignette")
### This is for if we are at least a six of the our max score
@export var percent_of_score_left_to_show_vignette: float = 6.0

@export_category("Score Costs")
@export_group("Wolf")
@export var drain_per_second: float = 50.0
@export var slash_cost: float = 25.0
@export var parry_cost: float = 250.0
@export var parry_points_per_bullet: float = 75.0

@export var slash_damage: float = 1.0
@export var wolf_parry_cd: float = 5.0
@export var wolf_claw_cd: float = .33

@export var wolf_swap_cost: float = 125
@export var wolf_speed: float = 220.0

@export_group("Sharp")
@export var shot_cost: float = 25.0
@export var shot_damage: int = 10
@export var shot_speed: float = 400.0
@export var shot_hit_reward_mult: float = 1.5
@export var dash_cost: float = 25.0

## How long action1 must be held to reach a full charge, in seconds.
@export var sharp_charge_time: float = 1.0
## Enough to one-shot Thiccums (thiccums_health = 50).
@export var sharp_charged_shot_damage: int = 60
@export var sharp_charged_shot_speed: float = 500.0
@export var sharp_charged_shot_scale: float = 2.2
@export var sharp_charged_shot_cost: float = 75.0

@export var sharp_shoot_cd: float = 1.0
@export var sharp_dash_cd: float = 1.0
@export var sharp_swap_cost: float = 250.0
@export var sharp_speed: float = 220.0
@export var dash_speed: float = 700.0
## How long the dash burst lasts, in physics frames.
@export var dash_frames: int = 10
## How many physics frames the player can't be hit, counted from dash start.
@export var dash_iframes: int = 20

@export_group("Mage")
@export var frost_cost: float = 25.0
@export var mage_frost_damage: int = 0
@export var mage_frost_slow: float = 0.50
@export var mage_slow_duration: float = 3.0
@export var mage_frost_cd: float = 1.0
@export var mage_explosion_damage: int = 2
@export var fire_ball_cost: float = 250.0
@export var mage_fireball_cd: float = 1.0
@export var mage_swap_cost: float = 250.0
@export var mage_speed: float = 220.0

@export_group("Zombie")
@export var zombie_speed: float = 70.0
@export var zombie_health: int = 2
@export var zombie_points_on_kill: int = 250
@export var zombie_points_on_kill_variance: int = 125
@export var zombie_damage: int = 250
@export var zombie_knockback_force: float = 300.0

@export_group("Thiccums")
@export var thiccums_speed: float = 30.0
@export var thiccums_health: int = 50
@export var thiccums_points_on_kill: int = 750
@export var thiccums_points_on_kill_variance: int = 125
@export var thiccums_big_aura_tick_damage: int = 125
@export var thiccums_knockback_force: float = 300.0

@export_group("Bat")
@export var bat_speed: float = 110.0
@export var bat_acceleration: float = 100.0
@export var bat_health: int = 2
@export var bat_keep_away_distance: float = 200.0
@export var bat_flee_acceleration_mult: float = 10.0
@export var bat_fire_interval_min: float = 1.6
@export var bat_fire_interval_max: float = 2.4
@export var bat_points_on_kill: int = 250
@export var bat_points_on_kill_variance: int = 125
@export var bat_bullet_damage: int = 250
@export var bat_bullet_speed: float = 150.0
@export var bat_knockback_force: float = 300.0
