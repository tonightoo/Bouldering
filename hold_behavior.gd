class_name HoldBehavior
extends Node2D

@export var hold_data: HoldData

var grabbed_time := 0.0
var grabbed_goal_time := 0.0
var grabbed_by_left := false
var grabbed_by_right := false
var is_grabbed_both: bool:
	get: return grabbed_by_left and grabbed_by_right
var is_grabbed_either: bool:
	get: return grabbed_by_left or grabbed_by_right
var respawn_timer := 0.0
var base_position: Vector2

var previous_position: Vector2
var position_delta: Vector2 = Vector2.ZERO

@onready var visual = $Visual
@onready var grab_area = $Grab2d/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = global_position
	previous_position = global_position
	visual.color = hold_data.color
	visual.size = hold_data.size
	visual.position = -hold_data.size * 0.5
	grab_area.shape.size = hold_data.size
	grab_area.position = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_grabbed_either:
		grabbed_time += delta
		
	# GoalのHoldを両手で3秒保持したらクリア
	if hold_data.type == HoldData.HoldType.GOAL and is_grabbed_both:
		grabbed_goal_time += delta
	elif hold_data.type == HoldData.HoldType.GOAL_RIGHT and grabbed_by_right:
		grabbed_goal_time += delta
	elif hold_data.type == HoldData.HoldType.GOAL_LEFT and grabbed_by_left: 
		grabbed_goal_time += delta	
	else:
		grabbed_goal_time = 0.0

	match hold_data.type:
		HoldData.HoldType.MOVING:
			update_moving(delta)
		HoldData.HoldType.FALLING:
			update_falling(delta)
		HoldData.HoldType.SLIPPERY:
			update_slip(delta)
			
		
	position_delta = global_position - previous_position

func update_moving(delta):
	if hold_data.move_period <= 0.0:
		return
	
	var t = Time.get_ticks_msec() / 1000.0
	var phase: float = (t + hold_data.move_phase) * TAU / hold_data.move_period
	var offset = sin(phase) * hold_data.move_amplitude
	global_position = base_position + hold_data.move_dir.normalized() * offset

func update_falling(delta):
	if grabbed_time > hold_data.fall_time:
		queue_free()
		
func update_slip(delta):
	pass
	#if is_grabbed:
		#hand_target.global_position += Vector2.DOWN * hold_data.slip_speed * delta

func get_movement_delta() -> Vector2:
	return position_delta
		
