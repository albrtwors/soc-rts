extends Node
class_name MainController

@onready var game_component: GameComponent = $GameComponent
@onready var level_container: Node3D = $LevelContainer
@onready var start_menu: StartMenuComponent = $UI_Canvas/StartMenuComponent
@onready var character_creation: CharacterCreationComponent = $UI_Canvas/CharacterCreationComponent
@onready var pause_menu: PauseMenuComponent = $UI_Canvas/PauseMenuComponent
@onready var ui_canvas: Control = $UI_Canvas
@onready var shop_component: ShopComponent = $GameComponent/ShopComponent
@onready var tutorial_component: TutorialComponent = $GameComponent/TutorialComponent

# ⚡ NUEVO: Referencia directa a la pantalla de carga en tu Canvas
@onready var loading_screen: LoadingScreenComponent = $UI_Canvas/LoadingScreen

var is_game_running: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_menu.start_new_game.connect(_on_start_new_game)
	start_menu.load_saved_game.connect(_on_load_saved_game)
	
	if character_creation:
		character_creation.profile_created.connect(_on_player_profile_created)
	
	await get_tree().create_timer(0.5).timeout
	
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.save_game.connect(_on_save_game)
	
	start_menu.visible = true
	if character_creation: 
		character_creation.visible = false
	pause_menu.visible = false
	if loading_screen:
		loading_screen.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_game_running:
		_toggle_pause()

func _on_start_new_game() -> void:
	start_menu.visible = false
	if character_creation:
		character_creation.visible = true
	else:
		_trigger_game_load_flow(true) # Flujo directo sin perfil

func _on_player_profile_created(p_name: String, p_lastname: String, p_age: int, p_role: String, p_avatar_path: String, p_pnf: String) -> void:
	if character_creation: 
		character_creation.visible = false
	
	# ⚡ CAMBIO CRÍTICO: Primero disparamos el flujo de carga.
	# Esto llamará a initialize_new_game() que reseteará el save a limpio.
	# Le pasamos los datos del formulario como argumentos para meterlos en el momento preciso.
	_trigger_game_load_flow(true, p_name, p_lastname, p_age, p_role, p_avatar_path, p_pnf)

func _on_load_saved_game() -> void:
	if game_component.has_save_file():
		start_menu.visible = false
		if character_creation: 
			character_creation.visible = false
			
		# ⚡ Entramos al flujo unificado de carga (es una partida vieja del disco)
		_trigger_game_load_flow(false)
	else:
		print("Operación cancelada: No existen datos de guardado previos.")

## 🔄 FLUJO UNIFICADO DE CARGA ASÍNCRONA/PROCESAL
## 🔄 FLUJO UNIFICADO DE CARGA ASÍNCRONA/PROCESAL
## 🔄 FLUJO UNIFICADO DE CARGA ASÍNCRONA/PROCESAL
func _trigger_game_load_flow(is_new_game: bool, p_name: String = "", p_lastname: String = "", p_age: int = 0, p_role: String = "", p_avatar_path: String = "", p_pnf: String = "") -> void:
	if loading_screen:
		loading_screen.start_loading()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# --- PASO 1: Procesar la carga física (Aquí create_new_game() resetea la RAM) ---
	if is_new_game:
		game_component.initialize_new_game(level_container)
		if tutorial_component:
			tutorial_component.start_new_player_tutorial()
	else:
		game_component.load_game(level_container)
	
	# --- ⚡ PASO 1.5: INYECCIÓN SEGURA DE DATOS ---
	# Ahora que la RAM está limpia y el nivel montado, le clavamos los datos reales antes de actualizar la UI
	if is_new_game:
		DataManager.current_save.player_name = p_name
		DataManager.current_save.player_lastname = p_lastname
		DataManager.current_save.player_age = p_age
		DataManager.current_save.player_role = p_role
		DataManager.current_save.player_avatar_path = p_avatar_path
		DataManager.current_save.player_pnf = p_pnf
	
	# Esperamos a que los nodos del nivel se acoplen bien
	await get_tree().process_frame
	
	# --- PASO 2: Refrescar la interfaz (Ahora sí leerá los datos reales inyectados) ---
	_update_player_ui()
	
	# --- PASO 3: Guardado inicial silencioso con los datos del formulario ya fijados ---
	if is_new_game:
		game_component.save_game(false)
	
	# --- PASO 4: Sostenemos la pantalla por 3 segundos para leer los tips del SOC ---
	await get_tree().create_timer(3.0).timeout
	
	# --- PASO 5: Levantamos la cortina y liberamos la jugabilidad ---
	is_game_running = true
	if loading_screen:
		loading_screen.stop_loading()
		
	# ⚡ PASO 6: Mensajes finales
	if is_new_game:
		ToastManager.show_toast("Administrador registrado con éxito", "MITIGACION")
	else:
		ToastManager.show_toast("Infraestructura del SOC cargada correctamente", "INFO")

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
