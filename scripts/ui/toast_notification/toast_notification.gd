extends PanelContainer
class_name ToastNotification

@onready var icon_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var message_label: Label = $MarginContainer/VBoxContainer/Label

## Configura el aspecto y texto del toast según el tipo de alerta
func setup(message: String, type: String, duration: float) -> void:
	message_label.text = message
	
	# Estilización según el contexto de ciberseguridad
	match type.to_upper():
		"INFO": # Tutoriales / Logs normales
			modulate = Color("#00bfff") # Cyan digital
		"ATAQUE": # ¡Alerta de Hacker entrante!
			modulate = Color("#ff3333") # Rojo crítico
		"MITIGACION": # Defensa exitosa
			modulate = Color("#33cc33") # Verde éxito
		_:
			modulate = Color.WHITE

	# Creamos un temporizador para que se desvanezca y se destruya solo
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(_on_duration_timeout)
	
	# Animación sutil de entrada (Fade-in)
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func _on_duration_timeout() -> void:
	# Animación sutil de salida (Fade-out) y borrado
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
