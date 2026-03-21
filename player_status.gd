class_name PlayerStatus
extends Resource

var config: PlayerConfig

var power_level: int = 1
var reach_level: int = 1
var speed_level: int = 1
var stamina_level: int = 1
var observation_level: int = 1

func _init(_config: PlayerConfig) -> void:
	self.config = _config

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
