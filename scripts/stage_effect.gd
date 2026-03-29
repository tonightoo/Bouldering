extends CanvasLayer

@onready var stage_label = $StageLabel
@export var display_stage_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalData.status.is_gameover:
		return
	var tween = create_tween()
	var final_position = Vector2(477.0, 291.5)
	tween.connect("finished", slide_out)
	tween.tween_property(stage_label, "position", final_position, 1.5)


func slide_out() -> void:
	await get_tree().create_timer(2.0).timeout
	var tween = create_tween()
	var final_position = Vector2(1454.0, 291.5)
	tween.tween_property(stage_label, "position", final_position, 1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
