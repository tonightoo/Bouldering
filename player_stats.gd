## プレイヤーステータスシステム
##
## プレイヤーの各種ステータスを管理し、
## ゲームのパラメータに影響を与える。
class_name PlayerStats
extends Resource

## ステータスの最小値
const MIN_STAT: float = 0.0
## ステータスの最大値
const MAX_STAT: float = 100.0

## 筋力（重いホールドの保持、落下ダメージ耐性）
@export var strength: float = 50.0
## 柔軟性（腕の伸び具合、難しい角度への対応）
@export var flexibility: float = 50.0
## 持久力（疲労の蓄積速度、回復速度）
@export var endurance: float = 50.0
## 体感（ボディポジショニング、肩の高さ活用）
@export var body_awareness: float = 50.0
## 精神力（ランジ時の安定性、冷静さ）
@export var mental_strength: float = 50.0
## オブザベ力（ホールドの見極め、スリップホール対応）
@export var observation: float = 50.0

## すべてのステータスを初期化
func _init() -> void:
	strength = clamp(strength, MIN_STAT, MAX_STAT)
	flexibility = clamp(flexibility, MIN_STAT, MAX_STAT)
	endurance = clamp(endurance, MIN_STAT, MAX_STAT)
	body_awareness = clamp(body_awareness, MIN_STAT, MAX_STAT)
	mental_strength = clamp(mental_strength, MIN_STAT, MAX_STAT)
	observation = clamp(observation, MIN_STAT, MAX_STAT)

## ステータスの値をクランプする
func clamp_stats() -> void:
	strength = clamp(strength, MIN_STAT, MAX_STAT)
	flexibility = clamp(flexibility, MIN_STAT, MAX_STAT)
	endurance = clamp(endurance, MIN_STAT, MAX_STAT)
	body_awareness = clamp(body_awareness, MIN_STAT, MAX_STAT)
	mental_strength = clamp(mental_strength, MIN_STAT, MAX_STAT)
	observation = clamp(observation, MIN_STAT, MAX_STAT)

## 全ステータスの平均値を取得
func get_average_stat() -> float:
	return (strength + flexibility + endurance + body_awareness + mental_strength + observation) / 6.0

## ステータスを文字列で取得（デバッグ用）
func to_string() -> String:
	return """
	PlayerStats:
	  筋力: %.1f
	  柔軟性: %.1f
	  持久力: %.1f
	  体感: %.1f
	  精神力: %.1f
	  オブザベ力: %.1f
	""" % [strength, flexibility, endurance, body_awareness, mental_strength, observation]
