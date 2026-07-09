extends PanelContainer
class_name TutorialPopup

# 🔍 Referencias de la Barra Lateral (Izquierda)
@onready var lesson_button_container: VBoxContainer = $MarginContainer/HBoxContainer/LeftSidebar/MarginContainer/VBoxContainer/ScrollContainer/LessonButtonContainer

# 🔍 Referencias del Contenido y Carrusel (Derecha)
@onready var carousel_view: PanelContainer = $MarginContainer/HBoxContainer/RightContentArea/CarouselView
@onready var lesson_image: TextureRect = $MarginContainer/HBoxContainer/RightContentArea/CarouselView/MarginContainer/VBoxContainer/LessonImage
@onready var lesson_title: Label = $MarginContainer/HBoxContainer/RightContentArea/CarouselView/MarginContainer/VBoxContainer/LessonTitle
@onready var lesson_description: Label = $MarginContainer/HBoxContainer/RightContentArea/CarouselView/MarginContainer/VBoxContainer/LessonDescription

# 🔍 Referencias de Navegación del Carrusel
@onready var prev_page_button: Button = $MarginContainer/HBoxContainer/RightContentArea/CarouselNavigation/PrevPageButton
@onready var next_page_button: Button = $MarginContainer/HBoxContainer/RightContentArea/CarouselNavigation/NextPageButton
@onready var dots_container: HBoxContainer = $MarginContainer/HBoxContainer/RightContentArea/CarouselNavigation/DotsContainer

# 🔍 Referencias del Panel de Objetivos Finales
@onready var action_panel: VBoxContainer = $MarginContainer/HBoxContainer/RightContentArea/ActionPanel
@onready var objectives_list: VBoxContainer = $MarginContainer/HBoxContainer/RightContentArea/ActionPanel/ObjectivesList

# ⚙️ Variables de control de estado interno
var _current_lesson: Dictionary = {}
var _current_page_index: int = 0
var _active_checkboxes: Dictionary = {} # ⚡ Mapeo lógico: { "id_tecnico": Nodo_CheckBox }

# 🎨 Nodos Molde (Templates extraídos en ejecución)
var _sidebar_button_template: BaseButton
var _dot_template: Panel
var _checkbox_template: CheckBox

func toggle() -> void:
	if visible:
		_animate_close()
	else:
		_animate_open()

func _ready() -> void:
	if has_node("/root/EventBus"):
		EventBus.start_tutorial.connect(func():
			_animate_open()
		)
		if EventBus.has_signal("objective_completed"):
			EventBus.objective_completed.connect(_on_objective_progressed)
	
	prev_page_button.pressed.connect(_on_prev_page_pressed)
	next_page_button.pressed.connect(_on_next_page_pressed)
		
	visible = false 
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	
	_extract_ui_templates()
	_initialize_sidebar_buttons()
	
	if not TutorialDatabase.LESSONS.is_empty():
		load_lesson(TutorialDatabase.LESSONS[0])

## 🎬 ANIMACIÓN: Apertura fluida (Pop + Fade) con efecto elástico
func _animate_open() -> void:
	if has_node("/root/EventBus"):
		EventBus.is_tutorial_popup_open = true # 🔒 Congela la cámara al abrir teoría
		
	# ⚡ SOLUCIÓN AL MENÚ VACÍO: Resetear paneles visibles antes de interpolar escala
	carousel_view.visible = true
	action_panel.visible = false
	
	# Buscamos de forma segura la lección que el TutorialComponent reporta como activa
	var active_id = "introduction_soc"
	var tutorial_component = get_tree().get_first_node_in_group("tutorial_component")
	if tutorial_component and !tutorial_component.current_lesson_id.is_empty():
		active_id = tutorial_component.current_lesson_id
	elif has_node("/root/TutorialComponent") and !get_node("/root/TutorialComponent").current_lesson_id.is_empty():
		active_id = get_node("/root/TutorialComponent").current_lesson_id
		
	# Cargamos los datos de teoría frescos para esa lección
	for lesson in TutorialDatabase.LESSONS:
		if lesson.get("id", "") == active_id:
			load_lesson(lesson)
			break

	visible = true
	await get_tree().process_frame
	pivot_offset = size / 2.0 
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## 🎬 ANIMACIÓN: Cierre suave difuminado
func _animate_close() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	await tween.finished
	visible = false
	
	if has_node("/root/EventBus"):
		EventBus.is_tutorial_popup_open = false # 🔓 Libera el movimiento de la cámara al cerrar

func _extract_ui_templates() -> void:
	if lesson_button_container.get_child_count() > 0:
		var original = lesson_button_container.get_child(0)
		_sidebar_button_template = original.duplicate() as BaseButton
		if _sidebar_button_template:
			_sidebar_button_template.button_pressed = false
	if dots_container.get_child_count() > 0:
		_dot_template = dots_container.get_child(0).duplicate() as Panel
	if objectives_list.get_child_count() > 0:
		_checkbox_template = objectives_list.get_child(0).duplicate() as CheckBox

## 📋 Genera los botones de la barra lateral leyendo el estado de bloqueos en disco
func _initialize_sidebar_buttons() -> void:
	for child in lesson_button_container.get_children():
		child.queue_free()
		
	var completed_list: Array = DataManager.current_save.completed_lessons
		
	for lesson in TutorialDatabase.LESSONS:
		var btn: BaseButton = _sidebar_button_template.duplicate() if _sidebar_button_template else Button.new()
		
		var lesson_id: String = lesson.get("id", "")
		var required: String = lesson.get("requires_lesson", "")
		
		var is_locked: bool = false
		if not required.is_empty() and not required in completed_list:
			is_locked = true
			
		var display_text: String = lesson.get("lesson_name", "Sin Nombre")
		if is_locked:
			display_text = "🔒 " + display_text
			
		if "text" in btn:
			btn.text = display_text
		elif btn.has_node("Label"): 
			btn.get_node("Label").text = display_text
		
		if is_locked:
			btn.disabled = true
			btn.modulate.a = 0.5 
		else:
			btn.disabled = false
			btn.modulate.a = 1.0
			btn.pressed.connect(func(): load_lesson(lesson))
			
		lesson_button_container.add_child(btn)

## 🔄 Carga una lección y sincroniza inmediatamente el backend
func load_lesson(lesson: Dictionary) -> void:
	_current_lesson = lesson
	_current_page_index = 0
	
	if has_node("/root/EventBus"):
		EventBus.lesson_selected.emit(lesson.get("id", ""))
	
	action_panel.visible = false
	carousel_view.visible = true
	
	_build_progress_dots()
	_display_current_page()

## ⚪ Instanciación de indicadores del carrusel
func _build_progress_dots() -> void:
	for child in dots_container.get_children():
		child.queue_free()
		
	var pages: Array = _current_lesson.get("pages", [])
	if _current_lesson.is_empty() or pages.is_empty(): return
	
	for i in range(pages.size()):
		var dot: Panel = _dot_template.duplicate() if _dot_template else Panel.new()
		dots_container.add_child(dot)

## 📺 Renderiza páginas de teoría multimedia
func _display_current_page() -> void:
	if has_node("MarginContainer/HBoxContainer/RightContentArea/CarouselNavigation"):
		$MarginContainer/HBoxContainer/RightContentArea/CarouselNavigation.visible = true
	
	var pages: Array = _current_lesson.get("pages", [])
	if _current_lesson.is_empty() or pages.is_empty(): return
	
	var page_data: Dictionary = pages[_current_page_index]
	lesson_title.text = page_data.get("title", "")
	lesson_description.text = page_data.get("description", "")
	
	var path: String = page_data.get("image_path", "")
	if not path.is_empty() and ResourceLoader.exists(path):
		lesson_image.texture = load(path) as Texture2D
		lesson_image.visible = true
	else:
		lesson_image.texture = null
		lesson_image.visible = false
	
	prev_page_button.disabled = (_current_page_index == 0)
	next_page_button.text = "Comenzar Lección" if _current_page_index == pages.size() - 1 else ">"
	
	_update_dots_visualization()

func _update_dots_visualization() -> void:
	var dots := dots_container.get_children()
	for i in range(dots.size()):
		dots[i].modulate = Color.CYAN if i == _current_page_index else Color.WHITE

func _on_prev_page_pressed() -> void:
	if _current_page_index > 0:
		_current_page_index -= 1
		_display_current_page()

func _on_next_page_pressed() -> void:
	var pages: Array = _current_lesson.get("pages", [])
	if _current_page_index < pages.size() - 1:
		_current_page_index += 1
		_display_current_page()
	else:
		_start_active_simulation()

## 🚀 Despacha las señales físicas de juego e inicializa el escenario 3D
func _start_active_simulation() -> void:
	var active_id: String = _current_lesson.get("id", "")
	if active_id.is_empty(): return
	
	# ⚡ SOLUCIÓN REPETIR LECCIONES: Limpiamos por código las variables de los trackers 3D
	if active_id == "introduction_soc":
		var movement_node = get_tree().get_first_node_in_group("movement_component")
		if movement_node:
			movement_node._accumulated_distance = 0.0
			movement_node._moving_objective_completed = false
			print("TutorialPopup: Reseteado tracker de movimiento para permitir repetición.")
	
	if has_node("/root/EventBus"):
		EventBus.game_session_started.emit(active_id)
		EventBus.is_in_tutorial = true
		
	_show_objectives_screen()
	_animate_close()

## 📊 Muestra la pantalla final de objetivos de la lección e indexa las referencias
func _show_objectives_screen() -> void:
	carousel_view.visible = false
	action_panel.visible = true
	_active_checkboxes.clear()
	
	for child in objectives_list.get_children():
		child.queue_free()
		
	var objectives: Array = _current_lesson.get("objectives", [])
	for obj in objectives:
		var check_box: CheckBox = _checkbox_template.duplicate() if _checkbox_template else CheckBox.new()
		check_box.text = str(obj.get("text", "Objetivo sin definir"))
		check_box.disabled = true 
		check_box.button_pressed = false
		objectives_list.add_child(check_box)
		
		var obj_id: String = obj.get("id", "")
		_active_checkboxes[obj_id] = check_box

## ⚡ REACCIÓN DE EVENTOS: Tilda el checkbox mapeado por ID técnica desde el mapa 3D
func _on_objective_progressed(objective_key: String) -> void:
	if _active_checkboxes.has(objective_key):
		var cb: CheckBox = _active_checkboxes[objective_key]
		if not cb.button_pressed:
			cb.button_pressed = true
			if has_node("/root/ToastManager"):
				ToastManager.show_toast("Objetivo cumplido", "INFO")
			_check_if_lesson_finished()

## 🔬 Comprobación de fin de ciclo para actualizar persistencia y refrescar UI
func _check_if_lesson_finished() -> void:
	var all_done = true
	for cb in _active_checkboxes.values():
		if not cb.button_pressed:
			all_done = false
			break
			
	if all_done and not _current_lesson.is_empty():
		var lesson_id = _current_lesson.get("id", "")
		var completed_list: Array = DataManager.current_save.completed_lessons
		
		if not lesson_id in completed_list:
			completed_list.append(lesson_id)
			DataManager.save_to_disk() 
			_initialize_sidebar_buttons() 
			
			if has_node("/root/ToastManager"):
				ToastManager.show_toast("¡Siguiente lección desbloqueada!", "MITIGACION")
