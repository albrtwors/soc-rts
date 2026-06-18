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
	else:
		print("No se pudo cargar: El archivo no existe.")

func save_game() -> void:
	# Simplemente delegamos la orden al Autoload
	DataManager.save_to_disk()

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
