extends Node2D

# 全体の流れをざっくり表す幹
@onready var root_path: Path2D = $RootPath
@onready var background_rect: TextureRect = $BackgroundTexture

@export var c_rank_holds: Array[HoldData]
@export var b_rank_holds: Array[HoldData]
@export var a_rank_holds: Array[HoldData]
@export var s_rank_holds: Array[HoldData]
@export var goal_holds: Array[HoldData]

# 全体パス作成時に使用する現在進行方向を示すアングル
var current_angle: float
# 全体パス作成時のサーチ回数
var search_num: int
# 全体パス作成時の1ステップの長さ
var step_length: int
# 全体パス作成時の現在地点
var current_point: Vector2
# 乱数生成用クラス
var rng: RandomNumberGenerator

# 全体パス作成時 進行方向を変更しない確率
const KEEP_DIRECTION_PERCENTANGE: float = 75.0
# ホールド位置決定時の候補作成試行回数
const CANDIDATE_NUM: int = 30
# ホールドの最大数
const HOLD_NUM: int = 30
# 最初のホールドの地面からの高さ
const INITIAL_HOLD_DISTANCE: float = 60.0
# ホールド間の距離最低値
const HOLD_DISTANCE_MIN: float = 100
# パスとの近さの得点率に使用する値
const CLOSE_RATE: float = 120
# Cランクのホールド確率
const C_RANK_PROBABILITY: float = 80.0
# Bランクのホールド確率
const B_RANK_PROBABILITY: float = 20.0
# Aランクのホールド確率
const A_RANK_PROBABILITY: float = 0.0
# Sランクのホールド確率
const S_RANK_PROBABILITY: float = 0.0

# ホールド用のシーン
var hold_scene = preload("res://hold.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()
	calcurate()

func calcurate() -> void:
	calcurate_main_bone()
	var holds_coordinates = generate_holds()
	holds_coordinates.sort_custom(sort_vectors)
	var holds_type: Array[HoldData]

	for i in range(holds_coordinates.size() - 1):
		var hold = hold_scene.instantiate()
		var hold_rand_value = rng.randf_range(0.0, 100.0)
		var index: int
		if hold_rand_value <= C_RANK_PROBABILITY:
			index = rng.randi_range(0, c_rank_holds.size() - 1)
			hold.hold_data = c_rank_holds.get(index)
		elif hold_rand_value <= C_RANK_PROBABILITY + B_RANK_PROBABILITY:
			index = rng.randi_range(0, b_rank_holds.size() - 1)
			hold.hold_data = b_rank_holds.get(index)
		elif hold_rand_value <= C_RANK_PROBABILITY + B_RANK_PROBABILITY + A_RANK_PROBABILITY:
			index = rng.randi_range(0, a_rank_holds.size() - 1)
			hold.hold_data = a_rank_holds.get(index)
		else:
			index = rng.randi_range(0, s_rank_holds.size() - 1)
			hold.hold_data = s_rank_holds.get(index)

		hold.global_position = holds_coordinates.get(i)
		add_child(hold)

	# 必ず一番高いところはゴールにする
	var goal_hold = hold_scene.instantiate()
	var goal_index: int = rng.randi_range(0, goal_holds.size() - 1)
	goal_hold.hold_data = goal_holds.get(goal_index)
	goal_hold.global_position = holds_coordinates.get(holds_coordinates.size() - 1)
	add_child(goal_hold)

	var bounds = Rect2(holds_coordinates[0], Vector2.ZERO)
	for h in holds_coordinates:
		bounds = bounds.expand(h)
	
	bounds = bounds.grow(200.0)
	background_rect.global_position = bounds.position
	background_rect.size = bounds.size

func sort_vectors(v1: Vector2, v2: Vector2) -> bool:
	if v1.y > v2.y:
		return true
	elif v1.y < v2.y:
		return false
	return v1.x < v2.x

func calcurate_main_bone() -> void:
	# まず全体の大きなながれとしてパスを生成する
	for i in range(search_num):
		var move_vector: Vector2 = Vector2.from_angle(deg_to_rad(current_angle)) * step_length
		var next_point: Vector2 = current_point + move_vector
		root_path.curve.add_point(next_point)
		current_point = next_point
		var random_value = rng.randf_range(0.0, 100.0)
		if random_value < KEEP_DIRECTION_PERCENTANGE:
			continue
		current_angle = rng.randf_range(-180.0, 0.0)

func generate_holds() -> Array[Vector2]:
	var active_list: Array[Vector2]
	var determined_list: Array[Vector2]
	var is_first_one: bool = true
	active_list.append(Vector2.ZERO)
	while(determined_list.size() <= HOLD_NUM):
		if active_list.size() == 0:
			break 
		var current_center: Vector2 = active_list.get(0)
		var hold_min_distance: float
		if is_first_one:
			hold_min_distance = INITIAL_HOLD_DISTANCE
			is_first_one = false
		else:
			hold_min_distance = HOLD_DISTANCE_MIN
		
		for i in range(CANDIDATE_NUM):
			var angle = rng.randf_range(-180.0, 0.0)
			var distance: float
			
			distance = hold_min_distance + hold_min_distance * sqrt(rng.randf_range(0.0, 1.0))
			var move_vector: Vector2 = Vector2.from_angle(deg_to_rad(angle)) * distance
			var candidate_point: Vector2 = current_center + move_vector
			var is_ng: bool = false
			for j in range(determined_list.size()):
				if candidate_point.distance_to(determined_list[j]) <= hold_min_distance:
					is_ng = true
			if is_ng:
				continue
			var closest_point: Vector2 = root_path.curve.get_closest_point(candidate_point)
			var distance_to_path: float = candidate_point.distance_to(closest_point)
			var threshold: float = clamp(1.0 - distance_to_path / CLOSE_RATE, 0.0, 1.0)
			var probability: float = rng.randf_range(0.0, 1.0)
			if probability <= threshold:
				determined_list.append(candidate_point)
				active_list.append(candidate_point)
				continue
		
		active_list.pop_front()
	
	return determined_list

func initialize() -> void:
	root_path.curve.clear_points()
	root_path.curve.add_point(Vector2.ZERO)
	current_point = Vector2.ZERO
	current_angle = -90.0
	search_num = 10
	step_length = 100
	rng = RandomNumberGenerator.new()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
