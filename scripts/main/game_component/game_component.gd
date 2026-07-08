extends Node
class_name GameComponent

@export var default_level_scene: PackedScene 

## Inicializa la escena 3D borrando lo anterior y preparando datos nuevos
func initialize_new_game(container: Node3D) -> void:
	_clear_current_level(container)
	DataManager.create_new_game() # El Autoload limpia los fondos
	_instantiate_level(container)

## Carga el nivel 3D basándose en lo que leyó el Autoload
func load_game(container: Node3D) -> void:
	# Le pedimos al Autoload que lea el disco
	if DataManager.load_from_disk():
		_clear_current_level(container)
		_instantiate_level(container)
		
		# ⚡ APALABRADO: Reconstruimos la red del SOC justo después de montar el mapa base
		_rebuild_infrastructure(container)
	else:
		print("No se pudo cargar: El archivo no existe.")

func save_game(show_notification: bool = true) -> void:
	# Simplemente delegamos la orden al Autoload
	DataManager.save_to_disk()
	if show_notification and has_node("/root/ToastManager"):
		ToastManager.show_toast("Partida Guardada", "INFO")

func has_save_file() -> bool:
	return ResourceLoader.exists(DataManager.SAVE_PATH)

func _instantiate_level(container: Node3D) -> void:
	if default_level_scene:
		var level_instance = default_level_scene.instantiate()
		container.add_child(level_instance)
	else:
		push_error("GameComponent: Olvidaste asignar la escena del nivel en el Inspector.")

func _clear_current_level(container: Node3D) -> void:
	for child in container.get_children():
		child.queue_free()

## 🛠️ FUNCIÓN DE RECONSTRUCCIÓN GENÉRICA
## Recorre el diccionario del save y levanta dinámicamente Racks, Impresoras, etc.
func _rebuild_infrastructure(container: Node3D) -> void:
	var saved_infrastructure: Dictionary = DataManager.current_save.servers
	
	for grid_key in saved_infrastructure.keys():
		var data: Dictionary = saved_infrastructure[grid_key]
		var cat: String = data.get("category", "")
		var subcat: String = data.get("subcategory", "")
		
		# Validamos que las claves existan en nuestra base de datos maestra
		if ItemDatabase.ITEMS.has(cat) and ItemDatabase.ITEMS[cat].has(subcat):
			var db_data: Dictionary = ItemDatabase.ITEMS[cat][subcat]
			var real_scene_path = db_data.get("3d_model", "")
			
			if real_scene_path != "" and ResourceLoader.exists(real_scene_path):
				var structure_scene = load(real_scene_path) as PackedScene
				if structure_scene:
					var instance = structure_scene.instantiate() as Node3D
					container.add_child(instance)
					
					# Posicionamiento exacto en el Grid en base a los datos flotantes guardados
					instance.global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
					
					# ⚡ COMPROMISO DE PERSISTENCIA: Al grupo unificado para que se pueda volver a guardar en caliente
					instance.add_to_group("InfraestructuraInstalada")
					
					# Inicialización del script unificado
					if instance is PlacedStructure:
						instance.setup_structure(cat, subcat, db_data)
					else:
						push_warning("GameComponent: El modelo instanciado en " + grid_key + " no posee el script PlacedStructure.")
			else:
				push_error("GameComponent: No se encontró la ruta del modelo 3D: " + real_scene_path)
