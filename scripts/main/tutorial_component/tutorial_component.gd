extends Node
class_name TutorialComponent

var is_active: bool = false
var current_step: int = 0

func _ready() -> void:
	if has_node("/root/EventBus"):
		EventBus.tutorial_step_advanced.connect(_on_tutorial_step_advanced)

## 🚀 Llamado por el MainController cuando la partida es 100% nueva
func start_new_player_tutorial() -> void:
	# Si ya lo completó en otra sesión, no hacemos nada
	if DataManager.current_save.is_tutorial_completed:
		return
		
	is_active = true
	EventBus.is_in_tutorial = true
	
	# DISPARO: Emitimos la señal global para que el popup se despierte solo
	if has_node("/root/EventBus"):
		EventBus.start_tutorial.emit()
		print("TutorialComponent: Señal start_tutorial emitida al EventBus.")

func _on_tutorial_step_advanced() -> void:
	if not is_active: return
	
	# Aquí puedes meter lógica de backend o desbloquear lecciones en el futuro
	print("TutorialComponent: El jugador avanzó un paso técnico en el mapa 3D.")

## 🎯 Se llamará cuando el jugador complete todo o cierre el menú definitivamente
func complete_tutorial() -> void:
	is_active = false
	EventBus.is_in_tutorial = false
	DataManager.current_save.is_tutorial_completed = true
	print("TutorialComponent: Tutorial marcado como completado con éxito.")
