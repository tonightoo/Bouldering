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
	hold_data = hold_data.duplicate(true)
	for i in hold_data.strategies.size():
		hold_data.strategies[i] = hold_data.strategies[i].duplicate(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_grabbed_either:
		grabbed_time += delta
	
	# リスポーン中のタイマー処理
	if respawn_timer > 0.0:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			# リスポーン
			respawn()

	for strategy in hold_data.strategies:
		strategy.update(self, delta)
		
	position_delta = global_position - previous_position

func start_respawn(respawn_time: float) -> void:
	respawn_timer = respawn_time

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
	tween.tween_property(visual_sprite, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(visual_sprite, "scale", Vector2.ONE, 0.3)

func lighten() -> void:
	var tween = create_tween()
	# 0.1秒で白っぽく光らせる（自己発光感を出す）
	tween.tween_property(visual_sprite, "modulate", Color(2.5, 2.5, 2.5), 0.1)


func unlighten() -> void:
	var tween = create_tween()
	# 0.2秒かけて元の色に戻す
	tween.tween_property(visual_sprite, "modulate", Color(1, 1, 1), 0.2)    
