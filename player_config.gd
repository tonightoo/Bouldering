class_name PlayerConfig
extends Resource

@export var HAND_SPEED: float = 150.0
@export var LEFT_UPPER_ARM_LEN: float = 32.0
@export var LEFT_FORE_ARM_LEN: float = 26.0
@export var RIGHT_UPPER_ARM_LEN: float = 32.0
@export var RIGHT_FORE_ARM_LEN: float = 26.0
@export var SHOULDER_MIN = deg_to_rad(-120)
@export var SHOULDER_MAX = deg_to_rad(120)
@export var ELBOW_MIN = deg_to_rad(10)
@export var ELBOW_MAX = deg_to_rad(150)
@export var SMOOTHNESS = 0.2
@export var BASE_FATIGUE_RATE: float = 4.0
@export var FATIGUE_RATE_OPEN_HAND: float = 3.0
@export var FATIGUE_RATE_BENT_ARM: float = 15.0
@export var FATIGUE_RATE_BODY_ABOVE: float = 1.6
@export var FATIGUE_RECOVERY_RATE: float = 20.0
@export var FATIGUE_BOTH_HANDS_REDUCE_RATE: float = 0.7
@export var BENT_ARM_THRESHOLD = deg_to_rad(90)
@export var ELBOW_EASY_ANGLE := deg_to_rad(15)
@export var ELBOW_HARD_ANGLE := deg_to_rad(90)
@export var MAX_FATIGUE: float = 100.0
@export var HEIGHT_DIFF_MAX: float = 40.0

var LEFT_ARM_MAX_LEN := LEFT_UPPER_ARM_LEN + LEFT_FORE_ARM_LEN
var LEFT_ARM_MIN_LEN := 10.0
var RIGHT_ARM_MAX_LEN := RIGHT_UPPER_ARM_LEN + RIGHT_FORE_ARM_LEN
var RIGHT_ARM_MIN_LEN := 10.0
