class_name PlayerStatus
extends Resource

var config: PlayerConfig

var power_level: int = 5
var reach_level: int = 5
var speed_level: int = 5
var stamina_level: int = 5
var observation_level: int = 5

var stage_level: int = 1

var skill_list: Array[SkillData]

func _init(_config: PlayerConfig) -> void:
	self.config = _config

# power
func get_lift_up_strength() -> float:
	var level: int = power_level + count_id(skill_list, "power_up")
	return config.LIFT_UP_STRENGTH + 10 * (level - 1)
	
func get_lunge_force() -> float:
	var level: int = power_level + count_id(skill_list, "power_up")
	return config.LUNGE_FORCE + 100 * (level - 1)
	
func get_keep_up_strength() -> float:
	var level: int = power_level + count_id(skill_list, "power_up")
	return config.KEEP_UP_STRENGTH + 20 * (level - 1)

# reach
func get_left_upper_arm_len() -> float:
	var level: int = reach_level + count_id(skill_list, "reach_up")	
	return config.LEFT_UPPER_ARM_LEN + 4 * (level - 1)

func get_left_fore_arm_len() -> float:
	var level: int = reach_level + count_id(skill_list, "reach_up")	
	return config.LEFT_FORE_ARM_LEN + 4 * (level - 1)
	
func get_right_upper_arm_len() -> float:
	var level: int = reach_level + count_id(skill_list, "reach_up")	
	return config.RIGHT_UPPER_ARM_LEN + 4 * (level - 1)

func get_right_fore_arm_len() -> float:
	var level: int = reach_level + count_id(skill_list, "reach_up")	
	return config.RIGHT_FORE_ARM_LEN + 4 * (level - 1)

# speed
func get_hand_max_speed() -> float:
	var level: int = speed_level + count_id(skill_list, "speed_up")	
	return config.HAND_MAX_SPEED + 20 * (level - 1)

func get_lunge_max_charge_time() -> float:
	var level: int = speed_level + count_id(skill_list, "speed_up")	
	return config.LUNGE_MAX_CHARGE_TIME - 0.3 * (level - 1)

# stamina
func get_max_fatigue() -> float:
	var level: int = stamina_level + count_id(skill_list, "stamina_up")	
	return config.MAX_FATIGUE + 10 * (level - 1)
	
func get_fatigue_recovery_rate() -> float:
	var level: int = stamina_level + count_id(skill_list, "stamina_up")	
	return config.FATIGUE_RECOVERY_RATE + 0.4 * (level - 1)

func get_fall_damage_max() -> float:
	var level: int = stamina_level + count_id(skill_list, "stamina_up")	
	return config.FALL_DAMAGE_MAX - 5 * (level - 1)

# observation
func get_observation_time_limit() -> float:
	var level: int = observation_level + count_id(skill_list, "observation_up")	
	return config.OBSERVATION_TIME_LIMIT + 1 * (level - 1)

func get_observation_camera_speed() -> float:
	var level: int = observation_level + count_id(skill_list, "observation_up")	
	var s_level: int = speed_level + count_id(skill_list, "speed_up")	
	return config.OBSERVATION_CAMERA_SPEED + 10 * (level - 1) + 10 * (s_level - 1)

func get_observation_vision_radius() -> float:
	var level: int = observation_level + count_id(skill_list, "observation_up")	
	return config.OBSERVATION_VISION_RADIUS + 5 * (level - 1)

func get_observation_darkness() -> float:
	var level: int = observation_level + count_id(skill_list, "observation_up")	
	return config.OBSERVATION_DARKNESS + 0.05 * (level - 1)

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
	return config.GRAVITY


func get_accel_max_x() -> float:
	return config.ACCEL_MAX_X

func get_accel_max_y() -> float:
	return config.ACCEL_MAX_Y

func get_left_arm_max_len() -> float:
	return get_left_upper_arm_len() + get_left_fore_arm_len() - get_left_elbow_overlap()

func get_left_arm_min_len() -> float:
	return config.LEFT_ARM_MIN_LEN

func get_right_arm_max_len() -> float:
	return get_right_upper_arm_len() + get_right_fore_arm_len() - get_right_elbow_overlap()

func get_right_arm_min_len() -> float:
	return config.RIGHT_ARM_MIN_LEN

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


func count_id(array: Array, target_id: String) -> int:
	var c = 0
	for item in array:
		if item.id == target_id:
			c += 1
	return c
