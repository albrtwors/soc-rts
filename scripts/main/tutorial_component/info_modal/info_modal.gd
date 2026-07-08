extends PanelContainer
class_name InfoModal

signal modal_closed

@onready var tutorial_texture: TextureRect = $"MarginContainer/VBoxContainer/Tutorial Image"
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var body_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var action_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if action_button:
		action_button.pressed.connect(_on_button_pressed)
		action_button.grab_focus()

	# 🎬 CONFIGURACIÓN INICIAL PARA LA ANIMACIÓN
	pivot_offset = size / 2.0 # Fijamos el pivote en el centro para que escale desde ahí
	self.modulate.a = 0.0     # Completamente invisible al inicio
	self.scale = Vector2(0.92, 0.92) # Ligeramente más pequeño
	
	# Ejecutamos la animación de entrada
	_play_entrance_animation()

## Llena los datos y la imagen dinámicamente
func setup(title: String, body_text: String, tutorial_img: Texture2D = null, button_text: String = "ENTENDIDO") -> void:
	if not is_node_ready():
		await ready
		
	title_label.text = title
	body_label.text = body_text
	action_button.text = button_text
	
	if tutorial_texture:
		if tutorial_img:
			tutorial_texture.texture = tutorial_img
			tutorial_texture.visible = true
		else:
			tutorial_texture.visible = false
			
	# Re-calculamos el pivote por si el tamaño cambió al inyectar los textos o la imagen
	pivot_offset = size / 2.0

## 🛠️ FUNCIÓN DE ANIMACIÓN DE ENTRADA (Fade-in + Pop-in)
func _play_entrance_animation() -> void:
	var tween := create_tween().set_parallel(true) # Corre ambas animaciones al mismo tiempo
	
	# 1. Animación de Opacidad (Fade-in) de 0.0 a 1.0
	tween.tween_property(self, "modulate:a", 1.0, 0.25)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
		
	# 2. Animación de Tamaño (Pop-in) de 0.92 a 1.0 de forma elástica/suave
	tween.tween_property(self, "scale", Vector2.ONE, 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_button_pressed() -> void:
	# Desconectamos el botón para evitar doble clic accidental durante la salida
	action_button.disabled = true
	
	# Lanzamos la animación de salida antes de destruir el nodo
	var tween := create_tween().set_parallel(true)
	
	tween.tween_property(self, "modulate:a", 0.0, 0.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
		
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	
	# Una vez terminada la animación de salida, emitimos la señal y destruimos
	tween.chain().tween_callback(func():
		modal_closed.emit()
		queue_free()
	)
