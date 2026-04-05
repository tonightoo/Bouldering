class_name RadarChart
extends Control

var config: PlayerConfig


func _draw() -> void:
	if config == null:
		return
	
	var center = size / 2
	var max_radius = 100
	var stats: Array[float] = [
		config.REACH_BASE_LEVEL,
		config.POWER_BASE_LEVEL,
		config.SPEED_BASE_LEVEL,
		config.STAMINA_BASE_LEVEL,
		config.OBSERVATION_BASE_LEVEL,
	]
	var points = PackedVector2Array()
	var label_margin = 30 # 頂点から文字までの距離
	var labels = ["Reach", "Power", "Speed", "Stamina", "Observation"]
	var font = get_theme_default_font()
	var font_size = get_theme_default_font_size()
	var ring_count = 5 # 円を何重にするか（例：0.2刻みで5本）
	var padding = 50
	
	for i in range(1, ring_count + 1):
		# 半径を段階的に大きくする (20, 40, 60, 80, 100)
		var r = max_radius * (float(i) / ring_count)
		#draw_arc(center, r, 0, TAU, 32, Color(1, 1, 1, 0.2), 1.0, false)	
		draw_arc(center, r, 0, TAU, 32, Color("9babb2"), 1.0, false)	

	for i in range(5):
		var angle = deg_to_rad(i * 72 - 90) # 真上から開始
		var r = max_radius * (stats[i] / 10)
		points.append(center + Vector2(cos(angle), sin(angle)) * r)

		# ステータスの名前を記載
		var label_pos = center + Vector2(cos(angle), sin(angle)) * (max_radius + label_margin)
		var text_size = font.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var final_pos = label_pos - (text_size / 2)
		final_pos.y += font.get_ascent(font_size) / 2
		#draw_string(font, final_pos, labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
		draw_string(font, final_pos, labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("2e222f"))

	#draw_polygon(points, [Color(1, 0.9, 0.5, 0.5)]) 
	draw_polygon(points, [Color("8ff8e2", 0.5)]) 
	#draw_polyline(points + PackedVector2Array([points[0]]), Color(1, 0.8, 0.3), 2.0)
	draw_polyline(points + PackedVector2Array([points[0]]), Color("ffffff"), 3.0)

	for point in points:
		var dot_size = Vector2(8, 8)
		var rect = Rect2(point - dot_size / 2, dot_size)
		draw_rect(rect, Color("30e1b9"))
