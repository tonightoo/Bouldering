class_name PlayerStatus
extends Resource


var config: PlayerConfig


var power_level: int = 5
var reach_level: int = 5
var speed_level: int = 5
var stamina_level: int = 5
var observation_level: int = 5

var stage_level: int = 1
var remaining_life: int = 3
var pause_enabled: bool = true

var skill_list: Array[SkillData]
var is_gameover: bool = false

var skill_slots: Dictionary[String, SkillData]

var gravity_bonus: float = 0.0

# おなら関係
var is_triggered_fart_lunge: bool = false
var fart_num: int

# ゴールのbounds
var stage_bounds: Rect2

func _init(_config: PlayerConfig) -> void:
	self.config = _config

func initialize() -> void:
	is_gameover = false
	skill_list.clear()
	skill_slots = {
		"square_action": config.SKILL_SLOTS["square_action"],
		"triangle_action": config.SKILL_SLOTS["triangle_action"],
		"circle_action": config.SKILL_SLOTS["circle_action"],
		"cross_action": config.SKILL_SLOTS["cross_action"],
		"up_action": config.SKILL_SLOTS["up_action"],
		"down_action": config.SKILL_SLOTS["up_action"],
		"left_action": config.SKILL_SLOTS["left_action"],
		"right_action": config.SKILL_SLOTS["right_action"],
	}
	remaining_life = get_max_life()
	recalcurate()

func reset_bonus() -> void:
	gravity_bonus = 0.0

func recalcurate() -> void:
	power_level = config.POWER_BASE_LEVEL + count_id(skill_list, "power_up")
	reach_level = config.REACH_BASE_LEVEL + count_id(skill_list, "reach_up")	
	speed_level = config.SPEED_BASE_LEVEL + count_id(skill_list, "speed_up")	
	stamina_level = config.STAMINA_BASE_LEVEL + count_id(skill_list, "stamina_up")	
	observation_level = config.OBSERVATION_BASE_LEVEL + count_id(skill_list, "observation_up")	
	pause_enabled = true
	fart_num = 0

# power
func get_lift_up_strength() -> float:
	return config.LIFT_UP_STRENGTH + 10 * (power_level - 1)
	
func get_lunge_force() -> float:
	return config.LUNGE_FORCE + 100 * (power_level - 1)
	
func get_keep_up_strength() -> float:
	return config.KEEP_UP_STRENGTH + 20 * (power_level - 1)

# reach
func get_left_upper_arm_len() -> float:
	return config.LEFT_UPPER_ARM_LEN + 4 * (reach_level - 1)

func get_left_fore_arm_len() -> float:
	return config.LEFT_FORE_ARM_LEN + 4 * (reach_level - 1)
	
func get_right_upper_arm_len() -> float:
	return config.RIGHT_UPPER_ARM_LEN + 4 * (reach_level - 1)

func get_right_fore_arm_len() -> float:
	return config.RIGHT_FORE_ARM_LEN + 4 * (reach_level - 1)

# speed
func get_hand_max_speed() -> float:
	return config.HAND_MAX_SPEED + 20 * (speed_level - 1)

func get_lunge_max_charge_time() -> float:
	return config.LUNGE_MAX_CHARGE_TIME - 0.3 * (speed_level - 1)

# stamina
func get_max_fatigue() -> float:
	return config.MAX_FATIGUE + 10 * (stamina_level - 1)
	
func get_fatigue_recovery_rate() -> float:
	return config.FATIGUE_RECOVERY_RATE + 0.4 * (stamina_level - 1)

func get_fall_damage_max() -> float:
	return config.FALL_DAMAGE_MAX - 5 * (stamina_level - 1)

# observation
func get_observation_time_limit() -> float:
	return config.OBSERVATION_TIME_LIMIT + 1 * (observation_level - 1)

func get_observation_camera_speed() -> float:
	return config.OBSERVATION_CAMERA_SPEED + 10 * (observation_level - 1) + 10 * (speed_level - 1)

func get_observation_vision_radius() -> float:
	return config.OBSERVATION_VISION_RADIUS + 5 * (observation_level - 1)

func get_observation_darkness() -> float:
	return config.OBSERVATION_DARKNESS + 0.05 * (observation_level - 1)

func get_input_force_strength() -> float:
	return config.INPUT_FORCE_STRENGTH

func get_hand_accel() -> float:
	return config.HAND_ACCEL

func get_hand_decel() -> float:
	return config.HAND_DECEL

func get_left_elbow_overlap() -> float:
	return config.LEFT_ELBOW_OVERLAP

func get_left_hand_overlap() -> float:
	return config.LEFT_HAND_OVERLAP

func get_right_elbow_overlap() -> float:
	return config.RIGHT_ELBOW_OVERLAP

func get_right_hand_overlap() -> float:
	return config.RIGHT_HAND_OVERLAP

func get_smoothness() -> float:
	return config.SMOOTHNESS

func get_fatigue_rate_open_hand() -> float:
	return config.FATIGUE_RATE_OPEN_HAND

func get_fatigue_rate_bent_arm() -> float:
	return config.FATIGUE_RATE_BENT_ARM

func get_fatigue_rate_body_above() -> float:
	return config.FATIGUE_RATE_BODY_ABOVE

func get_fatigue_both_hands_reduce_rate() -> float:
	return config.FATIGUE_BOTH_HANDS_REDUCE_RATE

func get_bent_arm_threshold() -> float:
	return config.BENT_ARM_THRESHOLD

func get_height_diff_max() -> float:
	return config.HEIGHT_DIFF_MAX

func get_goal_freeze_time() -> float:
	return config.GOAL_FREEZE_TIME

func get_lunge_input_threshold() -> float:
	return config.LUNGE_INPUT_THRESHOLD

func get_lunge_min_charge_time() -> float:
	return config.LUNGE_MIN_CHARGE_TIME

func get_lunge_cooldown() -> float:
	return config.LUNGE_COOLDOWN

func get_lunge_charge_time() -> float:
	return config.LUNGE_CHARGE_TIME

func get_lunge_charge_start_threshold() -> float:
	return config.LUNGE_CHARGE_START_THRESHOLD

func get_fall_damage_multiplier() -> float:
	return config.FALL_DAMAGE_MULTIPLIER

func get_air_resistance() -> float:
	return config.AIR_RESISTANCE


func get_gravity() -> float:
	return config.GRAVITY + gravity_bonus


func get_accel_max_x() -> float:
	return config.ACCEL_MAX_X

func get_accel_max_y() -> float:
	return config.ACCEL_MAX_Y

func get_initial_rotation() -> float:
	if get_gravity() >= 0:
		return config.INITIAL_ROTATION
	else:
		return PI

func get_left_arm_max_len() -> float:
	return get_left_upper_arm_len() + get_left_fore_arm_len() - get_left_elbow_overlap()

func get_left_arm_min_len() -> float:
	return config.LEFT_ARM_MIN_LEN

func get_right_arm_max_len() -> float:
	return get_right_upper_arm_len() + get_right_fore_arm_len() - get_right_elbow_overlap()

func get_right_arm_min_len() -> float:
	return config.RIGHT_ARM_MIN_LEN

func get_current_angle() -> float:
	return config.CURRENT_ANGLE

func get_search_num() -> int:
	return config.SEARCH_NUM

func get_step_length() -> int:
	return config.STEP_LENGTH

func get_keep_direction_percentage() -> float:
	return config.KEEP_DIRECTION_PERCENTANGE

func get_candidate_num() -> int:
	return config.CANDIDATE_NUM

func get_hold_num() -> int:
	return config.HOLD_NUM

func get_initial_hold_distance() -> float:
	return config.INITIAL_HOLD_DISTANCE

func get_hold_distance_min() -> float:
	return config.HOLD_DISTANCE_MIN

func get_close_rate() -> float:
	return config.CLOSE_RATE

func get_c_rank_probability() ->float:
	return config.C_RANK_PROBABILITY

func get_b_rank_probability() -> float:
	return config.B_RANK_PROBABILITY

func get_a_rank_probability() -> float:
	return config.A_RANK_PROBABILITY

func get_s_rank_probability() -> float:
	return config.S_RANK_PROBABILITY


func get_normal_drop_rate() -> float:
	return config.NORMAL_DROP_RATE

func get_rare_drop_rate() -> float:
	return config.RARE_DROP_RATE

func get_epic_drop_rate() -> float:
	return config.EPIC_DROP_RATE

func get_legendary_drop_rate() -> float:
	return config.LEGENDARY_DROP_RATE

func get_skill_candidate_num() -> int:
	return config.SKILL_CANDIDATE_NUM

func get_max_life() -> int:
	return config.MAX_LIFE

func get_fart_force() -> float:
	return config.FART_FORCE * pow(0.8, fart_num)

func get_left_fore_arm_sprite() -> Texture2D:
	return config.LEFT_FORE_ARM_SPRITE

func get_left_upper_arm_sprite() -> Texture2D:
	return config.LEFT_UPPER_ARM_SPRITE

func get_right_fore_arm_sprite() -> Texture2D:
	return config.RIGHT_FORE_ARM_SPRITE

func get_right_upper_arm_sprite() -> Texture2D:
	return config.RIGHT_UPPER_ARM_SPRITE

func get_body_sprite() -> Texture2D:
	return config.BODY_SPRITE

func get_head_sprite() -> Texture2D:
	return config.HEAD_SPRITE

func get_left_hand_sprite() -> SpriteFrames:
	return config.LEFT_HAND_SPRITES

func get_right_hand_sprite() -> SpriteFrames:
	return config.RIGHT_HAND_SPRITES

func set_remaining_life(new_life: int) -> void:
	remaining_life = clamp(new_life, 0, get_max_life())
	GlobalData.signals.life_changed.emit()
	if remaining_life == 0:
		is_gameover = true

func get_limit_time() -> float:
	return config.BASE_STAGE_TIME_LIMIT

func count_id(array: Array, target_id: String) -> int:
	var c = 0
	for item in array:
		if item.id == target_id:
			c += 1
	return c
