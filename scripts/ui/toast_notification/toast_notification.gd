extends PanelContainer
class_name ToastNotification

# Ruta exacta de tu árbol
@onready var message_label: Label = $MarginContainer/VBoxContainer/Label

## Configura el aspecto y texto del toast según el tipo de alerta
func setup(message: String, type: String, duration: float) -> void:
	# Esperamos a que el nodo esté listo en el árbol de escenas
	if not is_node_ready():
		await ready

	if not message_label:
		push_error("ToastNotification: No se encontró el Label en la ruta estática.")
		return

	# 1. Inyectamos el texto limpio
	message_label.text = message
	
	# 2. Definimos la paleta de colores reactiva de alto contraste
	var accent_color := Color.WHITE
	
	match type.to_upper():
		"INFO": 
			# Cyan Eléctrico (Tutoriales / Datos de Red)
			accent_color = Color("#00f0ff") 
		"ATAQUE": 
			# Rojo Neón Intenso (Intrusiones / Incidentes)
			accent_color = Color("#ff2a2a") 
		"MITIGACION": 
			# Verde Matriz Líquido (Contramedidas / Parches aplicados)
			accent_color = Color("#00ff66") 
		_:
			accent_color = Color("#e0e0e0")

	# 🛠️ SOLUCIÓN PARA LABEL_SETTINGS:
	# Si el nodo tiene asignado un LabelSettings, lo duplicamos para que el cambio de color
	# sea único para este Toast y alteramos su propiedad font_color interna.
	if message_label.label_settings:
		message_label.label_settings = message_label.label_settings.duplicate()
		message_label.label_settings.font_color = accent_color
	else:
		# Solución alternativa por si acaso en algún momento se lo quitas
		message_label.modulate = accent_color

	# --- ANIMACIÓN DE ENTRADA (FADE-IN) ---
	self.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Temporizador de vida en pantalla
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(_on_duration_timeout)

func _on_duration_timeout() -> void:
	# Animación de salida (Fade-out) y limpieza de RAM
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
