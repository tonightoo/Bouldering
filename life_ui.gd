extends CanvasLayer

@onready var container: HBoxContainer = $HBoxContainer

var life_fill_texture: Texture2D = preload("res://assets/images/life_fill.png")
var life_empty_texture: Texture2D = preload("res://assets/images/life_empty.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.signals.life_changed.connect(on_life_changed)
	on_life_changed()



func on_life_changed() -> void:
	# 全部消して
	for child in container.get_children():
		child.queue_free()

	# 残ってるライフ書いて
	for i in range(GlobalData.status.remaining_life):
		var life_sprite = TextureRect.new()
		life_sprite.custom_minimum_size = Vector2(32.0, 32.0)
		life_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		life_sprite.texture = life_fill_texture
		container.add_child(life_sprite)

	# 減ってるライフ書く
	for i in range(GlobalData.status.get_max_life() - GlobalData.status.remaining_life):
		var life_sprite = TextureRect.new()
		life_sprite.custom_minimum_size = Vector2(32.0, 32.0)
		life_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		life_sprite.texture = life_empty_texture
		container.add_child(life_sprite)
