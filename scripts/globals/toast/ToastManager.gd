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
		
	var target_container = targets[0] as VBoxContainer
	if not target_container:
		push_error("ToastManager: El nodo en 'toast_container' no es un VBoxContainer.")
		return
		
	if not toast_scene:
		push_error("ToastManager: No se pudo encontrar la escena toast_notification.tscn.")
		return
		
	# ⚡ CORRECCIÓN DE GODOT 4: La propiedad real es 'grow_vertical' 
	# Usamos la constante GROW_DIRECTION_BEGIN (que vale 0) para que crezca hacia ARRIBA
	target_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
		
	var toast_instance := toast_scene.instantiate() as ToastNotification
	
	# Añadimos el Toast directamente como hijo de tu contenedor maquetado
	target_container.add_child(toast_instance)
	
	# ⚡ REORDENAMIENTO EN CALIENTE: Lo mueve al índice 0 para que aparezca abajo
	target_container.move_child(toast_instance, 0)
	
	# Ejecutamos tu lógica original de forma segura
	toast_instance.setup(message, type, duration)
