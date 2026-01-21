class_name HoldBehavior
extends Node2D

@export var hold_data: HoldData

var grabbed_time := 0.0
var is_grabbed := false
var respawn_timer := 0.0
var base_position: Vector2

@onready var visual = $Visual
@onready var grab_area = $Grab2d/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = global_position
	visual.color = hold_data.color
	visual.size = hold_data.size
	visual.position = -hold_data.size * 0.5
	grab_area.shape.size = hold_data.size
	grab_area.position = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_grabbed:
		grabbed_time += delta

	match hold_data.type:
		HoldData.HoldType.MOVING:
			update_moving(delta)
		HoldData.HoldType.FALLING:
			update_falling(delta)
		HoldData.HoldType.SLIPPERY:
			update_slip(delta)

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

		
		
