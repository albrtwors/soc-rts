extends Node
class_name TutorialComponent

var is_active: bool = false
var current_lesson_id: String = ""

func _ready() -> void:
	if has_node("/root/EventBus"):
		# ⚡ Conectamos la señal que recibe el ID del objetivo avanzado desde los componentes (ej. MovementComponent)
		EventBus.tutorial_step_advanced.connect(_on_tutorial_step_advanced)
		
		# Conexión extra: Cuando el jugador selecciona una lección en la barra lateral
		if EventBus.has_signal("lesson_selected"):
			EventBus.lesson_selected.connect(_on_lesson_selected)

## 🚀 Llamado por el MainController cuando la partida es 100% nueva
func start_new_player_tutorial() -> void:
	if DataManager.current_save.is_tutorial_completed:
		return
		
	is_active = true
	EventBus.is_in_tutorial = true
	
	# Por defecto, si es nuevo, asumimos que arranca en la primera lección
	if not TutorialDatabase.LESSONS.is_empty():
		current_lesson_id = TutorialDatabase.LESSONS[0].get("id", "")
	
	if has_node("/root/EventBus"):
		EventBus.start_tutorial.emit()
		print("TutorialComponent: Menú inicial del tutorial desplegado.")

## 🎯 Escucha qué lección pinchó el usuario en la UI para cambiar el estado del backend
func _on_lesson_selected(lesson_id: String) -> void:
	current_lesson_id = lesson_id
	print("TutorialComponent: Sincronizado con la lección activa: ", lesson_id)

## ⚡ VALIDACIÓN ACTIVA: Escucha los impulsos de los componentes de juego
func _on_tutorial_step_advanced(objective_key: String) -> void:
	if not is_active or current_lesson_id.is_empty(): 
		return
		
	# Mapeo de validación directo contra la Base de Datos Única
	if _is_objective_valid_for_lesson(current_lesson_id, objective_key):
		print("TutorialComponent: ¡Acción válida detectada! -> ", objective_key)
		# Damos luz verde oficial: TutorialPopup y TutorialHUD reaccionarán a esto
		EventBus.objective_completed.emit(objective_key)
	else:
		print("TutorialComponent: Acción ignorada. '", objective_key, "' no pertenece a ", current_lesson_id)

## 🛠️ Método de validación dinámico contra la base de datos real
func _is_objective_valid_for_lesson(lesson_id: String, key: String) -> bool:
	var lesson_data := _get_lesson_data_by_id(lesson_id)
	if lesson_data.is_empty(): 
		return false
	
	var objectives: Array = lesson_data.get("objectives", [])
	for obj in objectives:
		if obj.get("id", "") == key:
			return true # La ID técnica existe dentro de los objetivos de la lección en la DB
			
	return false

## 🛠️ Auxiliar para buscar la lección exacta en la DB
func _get_lesson_data_by_id(id: String) -> Dictionary:
	if not has_node("/root/TutorialDatabase"):
		return {}
	for lesson in TutorialDatabase.LESSONS:
		if lesson.get("id", "") == id:
			return lesson
	return {}

## 🎯 Se llamará cuando el jugador complete el set entero de lecciones del SOC
func complete_tutorial() -> void:
	is_active = false
	current_lesson_id = ""
	EventBus.is_in_tutorial = false
	DataManager.current_save.is_tutorial_completed = true
	DataManager.save_to_disk()
	print("TutorialComponent: Sistema de inducción cerrado. Modo Sandbox libre.")
