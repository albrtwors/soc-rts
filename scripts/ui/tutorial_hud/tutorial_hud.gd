extends Control
class_name TutorialHUD

# ⚡ Nodos de la UI
@onready var lesson_badge_panel: TextureRect = $LessonBadgePanel
@onready var lesson_title_label: Label = $LessonTitleLabel
@onready var lesson_instruction_label: Label = $LessonInstructionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ⭕ Nodos Polimórficos de Lecciones Organizadas
@onready var movement_lesson: Node = $MovementLesson
@onready var hand_click: TextureRect = $MovementLesson/HandClick
@onready var shop_lesson: ShopLesson = $ShopLesson # 👈 Vinculamos el nuevo módulo

var _guide_tween: Tween
var _original_hand_pos: Vector2

func _ready() -> void:
	_hide_complete_hud()
	_original_hand_pos = hand_click.position
	
	if has_node("/root/EventBus"):
		EventBus.game_session_started.connect(_on_game_session_started)
		EventBus.objective_completed.connect(_on_objective_completed)
		EventBus.start_tutorial.connect(_hide_complete_hud)

func _hide_complete_hud() -> void:
	lesson_badge_panel.visible = false
	lesson_title_label.visible = false
	lesson_instruction_label.visible = false
	hand_click.visible = false
	
	if shop_lesson:
		shop_lesson.stop_guidance()
	if _guide_tween:
		_guide_tween.kill()

## 🎬 Se dispara al iniciar la simulación activa
func _on_game_session_started(lesson_id: String) -> void:
	var lesson_data = _get_lesson_data(lesson_id)
	if lesson_data.is_empty(): 
		return
	
	lesson_title_label.text = lesson_data.get("hud_level", "Nivel: Desconocido")
	lesson_instruction_label.text = lesson_data.get("hud_instruction", "")
	
	lesson_badge_panel.visible = true
	lesson_title_label.visible = true
	lesson_instruction_label.visible = true
	
	# 🎛️ Enrutador de Guías Visuales por ID de Lección:
	match lesson_id:
		"introduction_soc":
			hand_click.visible = true
			hand_click.modulate.a = 1.0
			hand_click.position = _original_hand_pos
			_start_smooth_drag_animation()
			
		"the_shop":
			# Levantamos las flechas animadas del script especializado de tienda
			shop_lesson.start_guidance()

## 🔓 Se ejecuta cuando el jugador cumple hitos técnicos
func _on_objective_completed(objective_key: String) -> void:
	# Manejo del objetivo de la Lección 1
	if objective_key == "moving":
		if _guide_tween:
			_guide_tween.kill()
		var fade_tween = create_tween()
		fade_tween.tween_property(hand_click, "modulate:a", 0.0, 0.3)
		await fade_tween.finished
		hand_click.visible = false
		_transition_to_next_popup()
		
	# Manejo del objetivo de la Lección 2 (Apertura de tienda)
	elif objective_key == "shop":
		# Mandamos a apagar la flecha animada por su propio método
		shop_lesson.stop_guidance()
		_transition_to_next_popup()

## 🔄 Rutina intermedia de espera y llamada al Popup
func _transition_to_next_popup() -> void:
	await get_tree().create_timer(1.0).timeout
	if has_node("/root/EventBus"):
		_hide_complete_hud()
		EventBus.start_tutorial.emit() # Reabre el popup teórico de inmediato

## 🎨 Animación elástica de arrastre (Lección 1)
func _start_smooth_drag_animation() -> void:
	if _guide_tween:
		_guide_tween.kill()
	_guide_tween = create_tween().set_loops()
	_guide_tween.tween_property(hand_click, "scale", Vector2(0.85, 0.85), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var target_drag_pos = _original_hand_pos + Vector2(150, 0)
	_guide_tween.tween_property(hand_click, "position", target_drag_pos, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_guide_tween.tween_property(hand_click, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_guide_tween.tween_property(hand_click, "modulate:a", 0.0, 0.2)
	_guide_tween.tween_callback(func(): hand_click.position = _original_hand_pos)
	_guide_tween.tween_property(hand_click, "modulate:a", 1.0, 0.2)

func _get_lesson_data(id: String) -> Dictionary:
	if not has_node("/root/TutorialDatabase"): 
		return {}
	for lesson in TutorialDatabase.LESSONS:
		if lesson.get("id", "") == id:
			return lesson
	return {}
