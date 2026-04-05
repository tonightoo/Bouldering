extends CanvasLayer

@onready var character_list: ItemList = $CharacterList
@onready var radar_chart: RadarChart = $Panel/RadarChart
@onready var active_skill_list = $ActiveSkillContainer
@onready var passive_skill_list = $PassiveSkillContainer
var axis_active: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_list.clear()
	
	for config_key in GlobalData.configs.keys():
		var config: PlayerConfig = GlobalData.configs[config_key]
		var index = character_list.add_item(config.CHARACTER_NAME, config.HEAD_SPRITE)
		character_list.set_item_metadata(index, config)
		
		if not config.IS_UNLOCKED:
			character_list.set_item_selectable(index, false)
			character_list.set_item_disabled(index, false)
			character_list.set_item_custom_fg_color(index, Color(0.5, 0.5, 0.5, 0.5))

	character_list.item_selected.connect(_on_item_selected)
	character_list.item_activated.connect(_on_item_activated)
	character_list.grab_focus()
	character_list.select(0)
	character_list.item_selected.emit(0)

func _process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if input_vector.length() > 0.5: # スティックを倒した
		if axis_active:
			process_grid_move(input_vector) # 選択を動かす自作関数
			axis_active = false
	else:
		axis_active = true
		
	if Input.is_action_just_pressed("ui_accept"):
		var current_index = character_list.get_selected_items()[0]
		character_list.item_activated.emit(current_index)

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func process_grid_move(input: Vector2) -> void:
	var max_items = character_list.get_item_count()
	if max_items == 0: return

	if abs(input.x) > abs(input.y):
		move_selection(1 if input.x > 0 else -1)
	else:
		move_selection(5 if input.y > 0 else -5)

func move_selection(offset: int):
	var max_items = character_list.get_item_count()
	var current_index = character_list.get_selected_items()[0]
	current_index = clampi(current_index + offset, 0, max_items - 1)
	
	# ItemList側の選択状態を更新
	character_list.select(current_index)
	character_list.item_selected.emit(current_index)


func _on_item_selected(index: int) -> void:
	var config: PlayerConfig = character_list.get_item_metadata(index)
	radar_chart.config = config
	radar_chart.queue_redraw()
	
	for child in active_skill_list.get_children():
		child.queue_free()

	for skill_key in config.SKILL_SLOTS.keys():
		var skill_rect = TextureRect.new()
		skill_rect.texture = config.SKILL_SLOTS[skill_key].texture
		skill_rect.custom_minimum_size = Vector2(64, 64)
		skill_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		skill_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		active_skill_list.add_child(skill_rect)

	for child in passive_skill_list.get_children():
		child.queue_free()
		
	for skill in config.SKILL_LIST:
		var skill_rect = TextureRect.new()
		skill_rect.texture = skill.texture
		skill_rect.custom_minimum_size = Vector2(64, 64)
		skill_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		skill_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		passive_skill_list.add_child(skill_rect)
	
	for i in 8 - config.SKILL_LIST.size():
		var skill_rect = TextureRect.new()
		skill_rect.texture = GlobalData.empty_skill.texture
		skill_rect.custom_minimum_size = Vector2(64, 64)
		skill_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		skill_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		passive_skill_list.add_child(skill_rect)
		
	

func _on_item_activated(index: int) -> void:
	var config: PlayerConfig = character_list.get_item_metadata(index)
	GlobalData.selected_character_name = config.CHARACTER_ID
	GlobalData.set_character()
	GlobalData.status.initialize()
	get_tree().change_scene_to_file("res://scenes/attempts_manager.tscn")
	
