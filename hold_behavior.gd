class_name HoldBehavior
extends Node2D

@export var hold_data: HoldData

@export var is_observed: bool = false
@export var is_confirmed: bool = false
var is_currently_visible: bool = false
var grabbed_time := 0.0
var grabbed_goal_time := 0.0
var grabbed_by_left := false
var grabbed_by_right := false
var hand_controller: Object = null  # HandController への参照
var enabled := true  # ホールドが掴める状態か
var is_grabbed_both: bool:
	get: return grabbed_by_left and grabbed_by_right
var is_grabbed_either: bool:
	get: return grabbed_by_left or grabbed_by_right
var respawn_timer := 0.0
var base_position: Vector2

var previous_position: Vector2
var position_delta: Vector2 = Vector2.ZERO

# 落下状態
var is_falling := false
var fall_velocity := 0.0
var fall_gravity := 980.0  # 標準重力加速度
var is_respawning := false  # リスポーン中か

@onready var visual_sprite = $VisualSprite
@onready var grab_area = $Grab2d/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = global_position
	previous_position = global_position
	#visual.color = hold_data.color
	#visual.size = hold_data.size
	#visual.position = -hold_data.size * 0.5
	#visual_sprite.texture = hold_data.texture
	visual_sprite.texture = hold_data.unknown_texture
	visual_sprite.scale = hold_data.size / visual_sprite.texture.get_size()
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
	
	# リスポーン中のタイマー処理
	if respawn_timer > 0.0:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			# リスポーン
			respawn()

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
	# 掴まれている時間が設定値を超えたら、落下開始
	if not is_falling and grabbed_time > hold_data.fall_time:
		is_falling = true
		enabled = false  # ホールドが掴めないようにする
		# ホールドが落ち始めた瞬間、掴んでいる手を離す
		if hand_controller != null:
			if grabbed_by_left:
				hand_controller.release_left_grab()
			if grabbed_by_right:
				hand_controller.release_right_grab()
	
	# 落下中は重力を適用
	if is_falling and not is_respawning:
		fall_velocity += fall_gravity * delta
		global_position.y += fall_velocity * delta
		
		# 画面外（大幅に下に落ちた）場合、非表示にしてリスポーン開始
		if global_position.y > base_position.y + 500:  # 基準位置から500px以上下に落ちた
			visible = false
			is_falling = false
			is_respawning = true
			if hold_data.respawn_time > 0.0:
				respawn_timer = hold_data.respawn_time
		
func update_slip(delta):
	pass

func respawn() -> void:
	# ホールドをリセット
	global_position = base_position
	visible = true
	enabled = true
	grabbed_time = 0.0
	grabbed_goal_time = 0.0
	grabbed_by_left = false
	grabbed_by_right = false
	is_falling = false
	is_respawning = false
	fall_velocity = 0.0
	#if is_grabbed:
		#hand_target.global_position += Vector2.DOWN * hold_data.slip_speed * delta

func get_movement_delta() -> Vector2:
	return position_delta
		

func update_visibility(is_observation: bool) -> void:
	if is_observation:
		if is_currently_visible:
			visual_sprite.modulate.a = 1.0
			is_observed = true
		elif is_observed and not is_currently_visible:
			visual_sprite.modulate.a = 0.3
		else:
			visual_sprite.modulate.a = 0.0
	else:
		if is_confirmed:
			visual_sprite.modulate.a = 1.0
		elif is_observed:
			visual_sprite.modulate.a = 1.0
		else:
			visual_sprite.modulate.a = 0.0

func confirm() -> void:
	is_confirmed = true
	visual_sprite.texture = hold_data.texture
	flash()
	
func flash() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(visual_sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(visual_sprite, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(visual_sprite, "scale", Vector2.ONE, 0.3)
	tween.tween_property(visual_sprite, "modulate", hold_data.color, 0.3)

func lighten() -> void:
	var tween = create_tween()
	# 0.1秒で白っぽく光らせる（自己発光感を出す）
	tween.tween_property(visual_sprite, "modulate", Color(2.5, 2.5, 2.5), 0.1)


func unlighten() -> void:
	var tween = create_tween()
	# 0.2秒かけて元の色に戻す
	tween.tween_property(visual_sprite, "modulate", Color(1, 1, 1), 0.2)    
