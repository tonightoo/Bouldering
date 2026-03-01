extends Node2D

@export var is_left := true
@export var bar_width := 40.0
@export var bar_height := 6.0
@export var x_offset := 40.0
@export var y_offset := -40.0

var fatigue := 0.0
@export var config: PlayerConfig

func _ready() -> void:
	config = PlayerConfig.new()

func _process(_delta):
	queue_redraw()

func _draw():
	var ratio := fatigue / config.MAX_FATIGUE
	var color := Color.GREEN.lerp(Color.RED, ratio)

	var pos := Vector2(-bar_width/2 + x_offset, y_offset)
	
	if ratio >= 0.7:
		var shake := sin(Time.get_ticks_msec() * 0.02) * 1.5
		pos.x += shake

	draw_rect(Rect2(pos, Vector2(bar_width, bar_height)), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(pos, Vector2(bar_width * ratio, bar_height)), color)
	
	var text := "Left:" if is_left else "Right:"
	
	draw_string(ThemeDB.fallback_font, pos + Vector2(0, -5), 
				text + str(int(fatigue)) + "%", 
				HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.BLACK)
