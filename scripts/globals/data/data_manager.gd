extends Node
# 🌍 AUTOLOAD GLOBAL: Guarda el estado de la partida en la RAM

const SAVE_PATH = "user://soc_save_game.tres"

# Aquí vive la información en tiempo real a la que todos accederán
var current_save: SaveData

func _ready() -> void:
	# El Autoload procesa siempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Inicializamos con un recurso vacío por si acaso
	current_save = SaveData.new()

## Crea un espacio de memoria limpio para una partida nueva
func create_new_game() -> void:
	current_save = SaveData.new()
	print("¡Datos globales reseteados para nueva partida!")

## Guarda el estado actual de la RAM en el disco duro (.tres)
func save_to_disk() -> void:
	if not current_save: return
	
	# Buscamos al Player vivo en la escena
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player:
		# 1. Guardamos su posición física real en el recurso
		current_save.player_position = player.global_position
		
		# 2. 🔴 CORRECCIÓN CRÍTICA: Forzamos al componente de movimiento a quedarse quieto
		# Evita que el target_position se quede apuntando a otro lado tras el guardado
		if player.movement_component:
			player.movement_component.target_position = player.global_position
			player.movement_component.is_moving_to_target = false
		
	var error := ResourceSaver.save(current_save, SAVE_PATH)
	if error == OK:
		print("¡Respaldo de datos exitoso en user:// sin desplazamientos!")
	else:
		print("Error crítico al guardar: ", error)

## Carga el archivo del disco y lo pasa a la RAM del Autoload
func load_from_disk() -> bool:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as SaveData
		print("¡Datos cargados! Capital disponible: ", current_save.money)
		return true
	return false
