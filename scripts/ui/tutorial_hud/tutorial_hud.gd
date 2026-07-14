extends Control
class_name TutorialHUD

# 🔍 Componentes base de la interfaz del HUD
@onready var lesson_badge_panel: TextureRect = $LessonBadgePanel
@onready var lesson_title_label: Label = $LessonTitleLabel
@onready var lesson_instruction_label: Label = $LessonInstructionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stop_watching_tutorial: Button = $StopWatchingTutorial

# 🛠️ Componentes de lecciones modulares (Hijos en tu árbol de escena)
@onready var movement_lesson: MovementLesson = $MovementLesson 
@onready var shop_lesson: ShopLesson = $ShopLesson
@onready var constructing_lesson: ConstructingLesson = $ConstructingLesson 

var _guide_tween: Tween

func _ready() -> void:
	_hide_complete_hud()
	
	# ⚡ Conectamos la pulsación del botón omitir/cancelar
	if stop_watching_tutorial:
		stop_watching_tutorial.pressed.connect(_on_skip_tutorial_pressed)
	
	if has_node("/root/EventBus"):
		EventBus.game_session_started.connect(_on_game_session_started)
		EventBus.objective_completed.connect(_on_objective_completed)
		EventBus.start_tutorial.connect(_hide_complete_hud)
		
		# 🔥 LA SOLUCIÓN: Si se cancela globalmente el tutorial, ocultamos el HUD de inmediato
		EventBus.cancel_current_tutorial.connect(_hide_complete_hud)

## Oculta todo el entorno gráfico y detiene las subtareas activas de cada lección
func _hide_complete_hud() -> void:
	lesson_badge_panel.visible = false
	lesson_title_label.visible = false
	lesson_instruction_label.visible = false
	
	if stop_watching_tutorial:
		stop_watching_tutorial.visible = false 
	
	# Force-stop a los elementos hijos para evitar que los tweens queden flotando
	if movement_lesson: movement_lesson.stop_lesson()
	if shop_lesson: shop_lesson.stop_guidance()
	if constructing_lesson: constructing_lesson.stop_lesson()
	if _guide_tween: _guide_tween.kill()

## Se dispara cuando el EventBus anuncia el arranque de una sesión práctica
func _on_game_session_started(lesson_id: String) -> void:
	var lesson_data = _get_lesson_data(lesson_id)
	if lesson_data.is_empty(): return
		
	lesson_title_label.text = lesson_data.get("hud_level", "Nivel: Desconocido")
	lesson_instruction_label.text = lesson_data.get("hud_instruction", "")
	
	lesson_badge_panel.visible = true
	lesson_title_label.visible = true
	lesson_instruction_label.visible = true
	
	if stop_watching_tutorial:
		stop_watching_tutorial.visible = true 
	
	match lesson_id:
		"introduction_soc", "movement_lesson": 
			if movement_lesson: 
				movement_lesson.start_lesson(self)
		"the_shop":
			if shop_lesson: 
				shop_lesson.start_guidance()
		"constructing_lesson":
			if constructing_lesson: 
				constructing_lesson.start_lesson(self)

## Reacción exclusiva a los hitos alcanzados en el gameplay
func _on_objective_completed(objective_key: String) -> void:
	print("📢 TutorialHUD: Hito detectado en juego -> ", objective_key)
	
	if objective_key in ["moving", "movement", "player_moved"]:
		if movement_lesson: 
			movement_lesson.stop_lesson()
		
		if has_node("/root/ToastManager"):
			ToastManager.show_toast("¡Excelente movimiento!", "INFO", 4.0)
			
		_transition_to_next_popup()
		
	elif objective_key == "shop":
		if shop_lesson: 
			shop_lesson.stop_guidance()
			
		if has_node("/root/ToastManager"):
			ToastManager.show_toast("Tienda completada", "INFO", 4.0)
			
		_transition_to_next_popup()
		
	elif objective_key in ["open_shop_build", "preview_started", "install_server"]:
		if constructing_lesson:
			constructing_lesson.handle_objective_progress(objective_key)
			if objective_key == "install_server":
				if has_node("/root/ToastManager"):
					ToastManager.show_toast("Servidor Instalado con Éxito", "INFO", 4.0)
				_transition_to_next_popup()

## Da paso al siguiente popup cuidando las transiciones
func _transition_to_next_popup() -> void:
	await get_tree().create_timer(1.3).timeout
	if has_node("/root/EventBus"):
		lesson_badge_panel.visible = false
		lesson_title_label.visible = false
		lesson_instruction_label.visible = false
		if stop_watching_tutorial:
			stop_watching_tutorial.visible = false
		
		EventBus.start_tutorial.emit()

## ⚡ El usuario decide cancelar toda la inducción activa
func _on_skip_tutorial_pressed() -> void:
	print("📢 TutorialHUD: El jugador presionó omitir el tutorial.")
	if has_node("/root/EventBus"):
		EventBus.cancel_current_tutorial.emit()

func _get_lesson_data(id: String) -> Dictionary:
	if not has_node("/root/TutorialDatabase"): 
		print("⚠️ TutorialHUD: No se encontró el Autoload /root/TutorialDatabase")
		return {}
		
	for lesson in TutorialDatabase.LESSONS:
		if lesson.get("id", "") == id: 
			return lesson
			
	return {}
