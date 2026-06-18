extends Node
class_name MainController

@onready var game_component: GameComponent = $GameComponent
@onready var level_container: Node3D = $LevelContainer
@onready var start_menu: StartMenuComponent = $UI_Canvas/StartMenuComponent
@onready var character_creation: CharacterCreationComponent = $UI_Canvas/CharacterCreationComponent
@onready var pause_menu: PauseMenuComponent = $UI_Canvas/PauseMenuComponent

# 🛠️ El tutorial ahora es manejado exclusivamente por el flujo principal de control
@onready var tutorial_component: TutorialComponent = $GameComponent/TutorialComponent

var is_game_running: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_menu.start_new_game.connect(_on_start_new_game)
	start_menu.load_saved_game.connect(_on_load_saved_game)
	
	if character_creation:
		character_creation.profile_created.connect(_on_player_profile_created)
	
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.save_game.connect(_on_save_game)
	
	start_menu.visible = true
	if character_creation: 
		character_creation.visible = false
	pause_menu.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_game_running:
		_toggle_pause()

func _on_start_new_game() -> void:
	start_menu.visible = false
	if character_creation:
		character_creation.visible = true
	else:
		is_game_running = true
		game_component.initialize_new_game(level_container)

func _on_player_profile_created(p_name: String, p_lastname: String, p_age: int, p_role: String, p_avatar_path: String) -> void:
	if character_creation: 
		character_creation.visible = false
	
	is_game_running = true
	
	# 1. El nivel 3D se instancia (Independiente)
	game_component.initialize_new_game(level_container)
	
	# 2. Inyectamos los datos del formulario a la RAM
	DataManager.current_save.player_name = p_name
	DataManager.current_save.player_lastname = p_lastname
	DataManager.current_save.player_age = p_age
	DataManager.current_save.player_role = p_role
	DataManager.current_save.player_avatar_path = p_avatar_path
	
	# 3. Buscamos y actualizamos la interfaz del jugador 
	_update_player_ui()
	
	# 4. 🛠️ DISPARO DEL TUTORIAL: Como es una partida totalmente nueva, le damos Play aquí mismo
	if tutorial_component:
		tutorial_component.start_new_player_tutorial()
	
	# 5. Guardamos en el disco duro (.tres)
	game_component.save_game()
	
	ToastManager.show_toast("Administrador registrado con éxito", "MITIGACION")

func _on_load_saved_game() -> void:
	if game_component.has_save_file():
		start_menu.visible = false
		if character_creation: 
			character_creation.visible = false
		is_game_running = true
		
		# Carga el nivel desde el disco
		game_component.load_game(level_container)
		
		# Buscamos la UI y reflejamos los datos
		_update_player_ui()
		
		# 🛠️ Al cargar una partida del disco, NO llamamos al tutorial, garantizando que permanezca apagado.
	else:
		print("Operación cancelada: No existen datos de guardado previos.")

func _update_player_ui() -> void:
	var player_ui = get_tree().get_first_node_in_group("player_ui") as UIComponent
	if player_ui:
		player_ui._initialize_player_profile()
	else:
		push_warning("MainController: No se encontró la UI del jugador en el grupo 'player_ui'.")

func _on_resume_game() -> void:
	_toggle_pause()

func _on_save_game() -> void:
	game_component.save_game()
	_toggle_pause()

func _toggle_pause() -> void:
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	pause_menu.visible = new_pause_state
