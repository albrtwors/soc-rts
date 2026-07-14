extends Control
class_name PauseMenuComponent

signal resume_game
signal save_game

@export var btn_resume: Button
@export var btn_save: Button
@export var btn_exit_to_menu: Button
@onready var game_menu_panel: GameMenuPanel = $GameMenuPanel

func _ready() -> void:
	# CRUCIAL: El menú de pausa debe poder recibir clicks cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	
	game_menu_panel.game_save_button.pressed.connect(func(): save_game.emit())
	game_menu_panel.game_start_button.pressed.connect(func():
			resume_game.emit()
	)
	# Despausa el árbol y limpia el estado volviendo a cargar la escena principal limpia
	game_menu_panel.exit_button.pressed.connect(func():
		game_menu_panel.visible = false
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
