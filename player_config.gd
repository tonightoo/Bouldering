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

var LEFT_ARM_MAX_LEN := LEFT_UPPER_ARM_LEN + LEFT_FORE_ARM_LEN
var LEFT_ARM_MIN_LEN := 10.0
var RIGHT_ARM_MAX_LEN := RIGHT_UPPER_ARM_LEN + RIGHT_FORE_ARM_LEN
var RIGHT_ARM_MIN_LEN := 10.0
