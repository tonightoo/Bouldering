class_name PlayerConfig
extends Resource

@export var HAND_MAX_SPEED: float = 150.0   # 最高速度
@export var HAND_ACCEL: float = 2000.0      # 加速力
@export var HAND_DECEL: float = 2500.0      # 減速力
@export var LEFT_UPPER_ARM_LEN: float = 32.0 # 左上腕の長さ
@export var LEFT_FORE_ARM_LEN: float = 32.0 # 左前腕の長さ
@export var LEFT_ELBOW_OVERLAP: float = 6.0 # 左肘の重なりの大きさ
@export var LEFT_HAND_OVERLAP: float = 2.0 # 左手の重なりの大きさ
@export var RIGHT_UPPER_ARM_LEN: float = 32.0 # 右上腕の長さ
@export var RIGHT_FORE_ARM_LEN: float = 32.0 # 右前腕の長さ
@export var RIGHT_ELBOW_OVERLAP: float = 6.0 # 右肘の重なりの大きさ
@export var RIGHT_HAND_OVERLAP: float = 2.0 # 右手の重なりの大きさ
@export var SMOOTHNESS = 0.2 # 
@export var FATIGUE_RATE_OPEN_HAND: float = 3.0 # 腕が伸び切っているときの疲労たまりレート
@export var FATIGUE_RATE_BENT_ARM: float = 15.0 # 腕を曲げているときの疲労たまりレート
@export var FATIGUE_RATE_BODY_ABOVE: float = 1.6 # 体が上にある時の疲労たまりレート
@export var FATIGUE_RECOVERY_RATE: float = 1.0 # 疲労が回復するレート
@export var FATIGUE_BOTH_HANDS_REDUCE_RATE: float = 0.7 # 両手持ちのときに疲労を軽減できる量
@export var BENT_ARM_THRESHOLD = deg_to_rad(90) # 腕を曲げる事のできる角度
@export var MAX_FATIGUE: float = 100.0 # 疲労度最大値
@export var HEIGHT_DIFF_MAX: float = 40.0 # 疲労度を計算する際の手が肩より高いときの疲労度増加MAXライン
@export var GOAL_FREEZE_TIME: float = 3.0 

@export var POWER_BASE_LEVEL: int = 5
@export var REACH_BASE_LEVEL: int = 5
@export var SPEED_BASE_LEVEL: int = 5
@export var STAMINA_BASE_LEVEL: int = 5
@export var OBSERVATION_BASE_LEVEL: int = 5

## 復帰可能最大数
@export var MAX_LIFE: int = 3

## ランジ（ダイノ）入力強度の閾値 (0.0-1.0)
@export var LUNGE_INPUT_THRESHOLD: float = 0.8
## ランジ発動までの入力継続時間（秒）
@export var LUNGE_CHARGE_TIME: float = 1.0
## ランジの発動力
@export var LUNGE_FORCE: float = 1000.0
## ランジ発動後のクールタイム（秒）
@export var LUNGE_COOLDOWN: float = 0.5
## ランジの最小チャージ時間（この時間以上ためないとランジは発動しない）
@export var LUNGE_MIN_CHARGE_TIME: float = 1.0
## ランジのチャージ開始の閾値（この時間入力を続けたらチャージ開始）
@export var LUNGE_CHARGE_START_THRESHOLD: float = 1.0
## ランジの最大チャージ時間（この時間以上ためてもLUNGE_FORCEは増えない）
@export var LUNGE_MAX_CHARGE_TIME: float = 5.0

## 落下ダメージの最大値（これ以上のダメージは発生しない）
@export var FALL_DAMAGE_MAX: float = 80.0
## 落下ダメージの係数（落下速度 × この値 = ダメージ）
@export var FALL_DAMAGE_MULTIPLIER: float = 0.1

## オブザベに使える時間
@export var OBSERVATION_TIME_LIMIT: float = 20.0
## オブザベ時のカメラスピード
@export var OBSERVATION_CAMERA_SPEED: float = 150.0
## オブザベ時の視界半径
@export var OBSERVATION_VISION_RADIUS: float = 50.0
## オブザベ時の暗さ(暗い 0.0~1.0 明るい)
@export var OBSERVATION_DARKNESS: float = 0.2

## 空気抵抗
@export var AIR_RESISTANCE: float = 0.98
## 入力による力
@export var INPUT_FORCE_STRENGTH: float = 300.0
## 重力加速度
@export var GRAVITY: float = 980.0
## 腕の持ち上げ力
@export var LIFT_UP_STRENGTH: float = 215.0
## 左右のキープ力
@export var KEEP_UP_STRENGTH: float = 215.0
## プレイヤーの加速制限値
@export var ACCEL_MAX_X: float = 300
@export var ACCEL_MAX_Y: float = 300

## プレイヤーが本来向いているべき方向
@export var INITIAL_ROTATION: float = 0.0

# ステージ生成関係

## 全体パス作成時 進行方向を変更しない確率
const KEEP_DIRECTION_PERCENTANGE: float = 75.0
## ホールド位置決定時の候補作成試行回数
const CANDIDATE_NUM: int = 30
## ホールドの最大数
const HOLD_NUM: int = 30
## 最初のホールドの地面からの高さ
const INITIAL_HOLD_DISTANCE: float = 60.0
## ホールド間の距離最低値
const HOLD_DISTANCE_MIN: float = 100
## パスとの近さの得点率に使用する値
const CLOSE_RATE: float = 120
## Cランクのホールド確率
const C_RANK_PROBABILITY: float = 80.0
## Bランクのホールド確率
const B_RANK_PROBABILITY: float = 20.0
## Aランクのホールド確率
const A_RANK_PROBABILITY: float = 0.0
## Sランクのホールド確率
const S_RANK_PROBABILITY: float = 0.0
## Normalスキルの排出確率
const NORMAL_DROP_RATE: float = 00.0
## Rareスキルの排出確率
const RARE_DROP_RATE: float = 100.0
## Epicスキルの排出確率
const EPIC_DROP_RATE: float = 0.0
## Legendaryスキルの排出確率
const LEGENDARY_DROP_RATE: float = 0.0
## 獲得スキル候補の数
const SKILL_CANDIDATE_NUM: int = 3
## タイムリミットの基礎値
const BASE_STAGE_TIME_LIMIT: float = 300


var LEFT_ARM_MAX_LEN := LEFT_UPPER_ARM_LEN + LEFT_FORE_ARM_LEN
var LEFT_ARM_MIN_LEN := 10.0
var RIGHT_ARM_MAX_LEN := RIGHT_UPPER_ARM_LEN + RIGHT_FORE_ARM_LEN
var RIGHT_ARM_MIN_LEN := 10.0
