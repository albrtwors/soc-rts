extends Node
class_name MovementLesson

@onready var hand_click: TextureRect = $HandClick
@onready var hand_drag: TextureRect = $HandDrag

var _hud: TutorialHUD
var _loop_tween: Tween

func _ready() -> void:
	# Nos aseguramos de que empiecen ocultos al cargar la escena
	if hand_click: hand_click.visible = false
	if hand_drag: hand_drag.visible = false

## Inicializa la lección y arranca el ciclo infinito de emulación de scroll
func start_lesson(hud_reference: TutorialHUD) -> void:
	_hud = hud_reference
	print("🖱️ MovementLesson: Emulando arrastre procedural con HandClick...")
	
	if not hand_click or not hand_drag:
		print("⚠️ MovementLesson: Faltan las referencias de los TextureRect hijos.")
		return
		
	_start_scroll_animation_loop()

## Detiene el bucle, mata los tweens activos y limpia la pantalla
func stop_lesson() -> void:
	print("🛑 MovementLesson: Deteniendo animación de arrastre.")
	if _loop_tween:
		_loop_tween.kill()
	
	if hand_click: hand_click.visible = false
	if hand_drag: hand_drag.visible = false

## Controla el ciclo repetitivo del movimiento de la mano
func _start_scroll_animation_loop() -> void:
	if _loop_tween:
		_loop_tween.kill()
		
	# Punto inicial y final del arrastre simulado (Ajusta los vectores según tu resolución)
	var start_pos := Vector2(500, 300)
	var end_pos := Vector2(500, 550)
	
	_loop_tween = create_tween().set_loops() # Bucle infinito hasta que se llame a stop_lesson()
	
	# Paso 1: Aparece el cursor de click libre arriba
	_loop_tween.tween_callback(func():
		hand_drag.visible = false
		hand_click.visible = true
		hand_click.position = start_pos
		hand_click.modulate.a = 0.0
	)
	_loop_tween.tween_property(hand_click, "modulate:a", 1.0, 0.2)
	_loop_tween.tween_interval(0.1)
	
	# Paso 2: Cambia al icono de arrastre (HandDrag) simulando que presiona el botón del mouse
	_loop_tween.tween_callback(func():
		hand_click.visible = false
		hand_drag.visible = true
		hand_drag.position = start_pos
	)
	_loop_tween.tween_interval(0.1)
	
	# Paso 3: Desplazamiento fluido hacia abajo (Emulación del Scroll)
	_loop_tween.tween_property(hand_drag, "position", end_pos, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_loop_tween.tween_interval(0.15)
	
	# Paso 4: Suelta el click (vuelve a HandClick) y se desvanece
	_loop_tween.tween_callback(func():
		hand_drag.visible = false
		hand_click.visible = true
		hand_click.position = end_pos
	)
	_loop_tween.tween_property(hand_click, "modulate:a", 0.0, 0.2)
	_loop_tween.tween_interval(0.4) # Pausa antes de reiniciar el ciclo
