# ModalManager.gd (Autoload Singleton)
extends Node

var modal_scene: PackedScene = preload("res://scenes/ui/modal/info_modal/info_modal.tscn") # Ajusta tu ruta real

signal modal_resolved

func show_modal(title: String, body: String, tutorial_img: Texture2D = null, button_text: String = "ENTENDIDO") -> void:
	var player_ui = get_tree().get_first_node_in_group("player_ui") as Control
	var target_container: Node = null
	
	if player_ui:
		target_container = player_ui.get_parent()
	else:
		target_container = get_tree().current_scene
		push_warning("ModalManager: No se encontró 'player_ui', usando la raíz de la escena actual.")

	if not target_container:
		return
		
	var modal_instance = modal_scene.instantiate() as InfoModal
	target_container.add_child(modal_instance)
	
	modal_instance.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	
	# 🔴 BLOQUEO: Congelamos cámara
	EventBus.is_in_tutorial = true
	
	modal_instance.setup(title, body, tutorial_img, button_text)
	
	# Capturamos el cierre respetando la cola de la animación de salida
	modal_instance.modal_closed.connect(func():
		# 🟢 DESBLOQUEO: Liberamos cámara
		EventBus.is_in_tutorial = false
		modal_resolved.emit()
	)
