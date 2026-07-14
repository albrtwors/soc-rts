extends Node
class_name ShopLesson

@onready var arrow_indicator: TextureRect = $ArrowIndicator # Asegúrate de que se llame así tu flecha

var _bounce_tween: Tween

func _ready() -> void:
	arrow_indicator.visible = false

## 🎬 Activa la guía visual y su animación cuando arranca el nivel de la tienda
func start_guidance() -> void:
	arrow_indicator.visible = true
	arrow_indicator.modulate.a = 1.0
	_start_bounce_animation()

## 🔓 Detiene la animación y desvanece la flecha al cumplir el objetivo
func stop_guidance() -> void:
	if _bounce_tween:
		_bounce_tween.kill()
		
	var fade = create_tween()
	fade.tween_property(arrow_indicator, "modulate:a", 0.0, 0.3)
	await fade.finished
	arrow_indicator.visible = false

## 🔄 Bucle elástico (Efecto rebote / Bounce) para llamar la atención del jugador
func _start_bounce_animation() -> void:
	if _bounce_tween:
		_bounce_tween.kill()
		
	_bounce_tween = create_tween().set_loops()
	var original_pos = arrow_indicator.position
	
	# Sube 15 píxeles suavemente
	_bounce_tween.tween_property(arrow_indicator, "position", original_pos + Vector2(0, -15), 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Baja de golpe simulando gravedad
	_bounce_tween.tween_property(arrow_indicator, "position", original_pos, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
