extends Node
# 🌍 AUTOLOAD GLOBAL: Guarda el estado de la partida en la RAM

const SAVE_PATH = "user://soc_save_game.tres"
var current_save: SaveData

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Si no existe archivo previo, instanciamos una plantilla limpia
	if not load_from_disk():
		current_save = SaveData.new()

func create_new_game() -> void:
	current_save = SaveData.new()
	# Nos aseguramos de que el array empiece completamente vacío de candados
	current_save.completed_lessons = []
	
	# ⚡ COMPROMISO DE BORRADO: Sobrescribimos el archivo en el disco de inmediato para eliminar el progreso viejo
	var error := ResourceSaver.save(current_save, SAVE_PATH)
	if error == OK:
		print("¡Archivo de guardado físico limpiado con éxito en el disco!")
	else:
		print("Advertencia al limpiar archivo físico: ", error)
		
	print("¡Datos globales y progreso de tutoriales reseteados para nueva partida!")
	
func save_to_disk() -> void:
	if not current_save: return
	
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player:
		current_save.player_position = player.global_position
		if player.movement_component:
			player.movement_component.target_position = player.global_position
			player.movement_component.is_moving_to_target = false
			
	# Recolectamos las estructuras instaladas en el SOC
	var serialized_infrastructure = {}
	var installed_items = get_tree().get_nodes_in_group("InfraestructuraInstalada")
	
	for item in installed_items:
		if item is PlacedStructure:
			var grid_key = str(round(item.global_position.x)) + "," + str(round(item.global_position.z))
			
			serialized_infrastructure[grid_key] = {
				"category": item.category,
				"subcategory": item.subcategory,
				"pos_x": item.global_position.x,
				"pos_y": item.global_position.y,
				"pos_z": item.global_position.z
			}
			
	current_save.servers = serialized_infrastructure
	
	# Al guardar el recurso, Godot meterá automáticamente completed_lessons gracias al @export
	var error := ResourceSaver.save(current_save, SAVE_PATH)
	if error == OK:
		print("¡Respaldo de datos, infraestructura y tutoriales exitoso en user://!")
	else:
		print("Error crítico al guardar en disco: ", error)

func load_from_disk() -> bool:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as SaveData
		print("¡Datos cargados del disco! Lecciones completadas detectadas: ", current_save.completed_lessons.size())
		return true
	return false
