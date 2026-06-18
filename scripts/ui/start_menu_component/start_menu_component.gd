extends Control
class_name StartMenuComponent

signal start_new_game
signal load_saved_game

@export var btn_new_game: Button
@export var btn_load_game: Button
@export var btn_exit: Button

func _ready() -> void:
	# Forzamos que ocupe todo el espacio de la pantalla
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	btn_new_game.pressed.connect(func(): start_new_game.emit())
	btn_load_game.pressed.connect(func(): load_saved_game.emit())
	btn_exit.pressed.connect(func(): get_tree().quit())
