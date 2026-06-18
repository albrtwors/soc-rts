extends Node
# 🌍 AUTOLOAD GLOBAL: ToastManager

var toast_scene: PackedScene = preload("res://scenes/ui/toast/toast_notification.tscn")

## Función pública universal para lanzar alertas desde cualquier parte del juego
func show_toast(message: String, type: String = "INFO", duration: float = 4.0) -> void:
	# 🔍 Buscamos el contenedor manual en la UI usando tu grupo
	var targets = get_tree().get_nodes_in_group("toast_container")
	if targets.is_empty():
		push_error("ToastManager: No se encontró ningún contenedor en el grupo 'toast_container'.")
		return
		
	var target_container = targets[0]
	
	if not toast_scene:
		push_error("ToastManager: No se pudo encontrar la escena toast_notification.tscn.")
		return
		
	var toast_instance := toast_scene.instantiate() as ToastNotification
	
	# Añadimos el Toast directamente como hijo de tu contenedor maquetado
	target_container.add_child(toast_instance)
	
	# Ejecutamos tu lógica original de forma segura
	toast_instance.setup(message, type, duration)
