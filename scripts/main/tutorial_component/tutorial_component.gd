extends Node
class_name TutorialComponent

var is_active: bool = false
var current_step: int = 0

## El MainController llamará a esto únicamente cuando se inicie una partida NUEVA de verdad
func start_new_player_tutorial() -> void:
	# Verificación de seguridad usando los datos en memoria
	if DataManager.current_save.is_tutorial_completed:
		return
		
	is_active = true
	current_step = 1
	_execute_step()

func _execute_step() -> void:
	match current_step:
		1:
			ToastManager.show_toast("Bienvenido. Arrastra el mouse con click izquierdo para moverte por el mapa.", "INFO", 10)
		2:
			ToastManager.show_toast("Intenta Comprar tu primer servidor", "WARNING")
		3:
			_complete_tutorial()

## El sistema o eventos externos pueden avisar de un avance sin acoplarse
func advance_step() -> void:
	if not is_active: return
	current_step += 1
	_execute_step()

func _complete_tutorial() -> void:
	is_active = false
	DataManager.current_save.is_tutorial_completed = true
	ToastManager.show_toast("Inducción completada. El laboratorio está bajo tu control.", "MITIGACION")
