extends Node
class_name TutorialComponent

var is_active: bool = false
var current_lesson_id: String = ""

func _ready() -> void:
	add_to_group("tutorial_component")
	if has_node("/root/EventBus"):
		EventBus.tutorial_step_advanced.connect(_on_tutorial_step_advanced)
		EventBus.cancel_current_tutorial.connect(complete_tutorial) # 👈 Omitir
		
		if EventBus.has_signal("lesson_selected"):
			EventBus.lesson_selected.connect(_on_lesson_selected)

func start_new_player_tutorial() -> void:
	if DataManager.current_save.is_tutorial_completed: return
	is_active = true
	EventBus.is_in_tutorial = true
	
	if not TutorialDatabase.LESSONS.is_empty():
		current_lesson_id = TutorialDatabase.LESSONS[0].get("id", "")
	
	if has_node("/root/EventBus"):
		EventBus.start_tutorial.emit()

func _on_lesson_selected(lesson_id: String) -> void:
	current_lesson_id = lesson_id
	if has_node("/root/EventBus"):
		EventBus.force_close_game_interfaces.emit()

func _on_tutorial_step_advanced(objective_key: String) -> void:
	# Permitir validaciones de re-visualización manual incluso si no es una partida nueva
	if current_lesson_id.is_empty(): return
		
	if _is_objective_valid_for_lesson(current_lesson_id, objective_key):
		print("TutorialComponent: Acción validada -> ", objective_key)
		EventBus.objective_completed.emit(objective_key)
		
		_check_and_unlock_lesson_progression(objective_key)
	else:
		print("TutorialComponent: Bloqueado. '", objective_key, "' no pertenece a ", current_lesson_id)

func _is_objective_valid_for_lesson(lesson_id: String, key: String) -> bool:
	var lesson_data := _get_lesson_data_by_id(lesson_id)
	if lesson_data.is_empty(): return false
	
	var objectives: Array = lesson_data.get("objectives", [])
	for obj in objectives:
		if obj.get("id", "") == key: return true
	return false

func _check_and_unlock_lesson_progression(completed_key: String) -> void:
	var lesson_data := _get_lesson_data_by_id(current_lesson_id)
	if lesson_data.is_empty(): return
	
	var objectives: Array = lesson_data.get("objectives", [])
	if objectives.is_empty(): return
	
	var last_objective = objectives[-1]
	if last_objective.get("id", "") == completed_key:
		var completed_list: Array = DataManager.current_save.completed_lessons
		if not current_lesson_id in completed_list:
			completed_list.append(current_lesson_id)
			print("💾 TutorialComponent: Lección '", current_lesson_id, "' completada y desbloqueada globalmente.")
			
			# Si es la última lección del juego, cerramos la inducción automática
			if current_lesson_id == TutorialDatabase.LESSONS[-1].get("id", ""):
				complete_tutorial()

## 🎯 Apaga de forma definitiva el modo tutorial forzado y abre el Sandbox
func complete_tutorial() -> void:
	is_active = false
	current_lesson_id = ""
	EventBus.is_in_tutorial = false
	DataManager.current_save.is_tutorial_completed = true
	# DataManager.save_to_disk() # 💾 Descomenta para guardar la omisión físicamente
	
	if has_node("/root/EventBus"):
		EventBus.force_close_game_interfaces.emit()
		
	if has_node("/root/ToastManager"):
		ToastManager.show_toast("Tutorial omitido. Modo Sandbox Libre.", "INFO", 4.0)

func _get_lesson_data_by_id(id: String) -> Dictionary:
	if not has_node("/root/TutorialDatabase"): return {}
	for lesson in TutorialDatabase.LESSONS:
		if lesson.get("id", "") == id: return lesson
	return {}
