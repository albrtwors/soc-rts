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

# 🛠️ NUEVA REFERENCIA: Tu menú personalizado de juego en la parte derecha
# (Asegúrate de ajustar esta ruta al nodo real que crees dentro de RightContentArea)
@onready var game_menu_panel: GameMenuPanel = $MarginContainer/HBoxContainer/RightContentArea/GameMenuPanel

# ⚙️ Variables de control de estado interno
var _current_lesson: Dictionary = {}
var _current_page_index: int = 0

# 🎨 Nodos Molde
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
			_animate_open() # ⚡ Cambiado para que use la animación suave en vez de un corte seco
		)
	
	prev_page_button.pressed.connect(_on_prev_page_pressed)
	next_page_button.pressed.connect(_on_next_page_pressed)
	
	#conectar botones del game panel
	game_menu_panel.game_start_button.pressed.connect(func(): 
		visible = !visible
		EventBus.is_in_tutorial = false
		
	)
	# Inicializamos los valores para que el Tween tenga un punto de partida limpio
	visible = false 
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	
	_extract_ui_templates()
	_initialize_sidebar_buttons()
	
	if not TutorialDatabase.LESSONS.is_empty():
		load_lesson(TutorialDatabase.LESSONS[0])

## 🎬 ANIMACIÓN: Apertura fluida (Pop + Fade)
func _animate_open() -> void:
	visible = true
	
	# Esperamos un microsegundo para asegurarnos de que el contenedor calculó su tamaño
	await get_tree().process_frame
	pivot_offset = size / 2.0 # Forzamos el pivote en el centro real del panel
	
	var tween = create_tween().set_parallel(true)
	# Transición tipo "Back" para dar un leve efecto de rebote elástico al final
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

## 🎬 ANIMACIÓN: Cierre suave
func _animate_close() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Esperamos a que termine el Tween para apagar el procesamiento visual del nodo
	await tween.finished
	visible = false
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

## 📋 Genera los botones de la BD + El botón especial del Menú de Juego
func _initialize_sidebar_buttons() -> void:
	for child in lesson_button_container.get_children():
		child.queue_free()
		
	# 1. Cargamos los botones normales de la Base de Datos
	for lesson in TutorialDatabase.LESSONS:
		var btn: BaseButton = _sidebar_button_template.duplicate() if _sidebar_button_template else Button.new()
		
		if "text" in btn:
			btn.text = lesson.get("lesson_name", "Sin Nombre")
		elif btn.has_node("Label"): 
			btn.get_node("Label").text = lesson.get("lesson_name", "Sin Nombre")
		
		btn.pressed.connect(func(): load_lesson(lesson))
		lesson_button_container.add_child(btn)
		
	# 2. 🌟 INYECTAMOS EL BOTÓN EXTRA PARA EL MENÚ GENERAL DE JUEGO
	var menu_btn: BaseButton = _sidebar_button_template.duplicate() if _sidebar_button_template else Button.new()
	
	if "text" in menu_btn:
		menu_btn.text = "⚙️ Menú de Juego"
	elif menu_btn.has_node("Label"):
		menu_btn.get_node("Label").text = "⚙️ Menú de Juego"
		
	# Conectamos este botón a una función especial que limpia la derecha y muestra tu menú
	menu_btn.pressed.connect(_open_game_menu)
	lesson_button_container.add_child(menu_btn)

## 🔄 Carga una lección normal de la BD
func load_lesson(lesson: Dictionary) -> void:
	_current_lesson = lesson
	_current_page_index = 0
	
	# Aseguramos que el menú de juego se oculte al volver a las lecciones
	if game_menu_panel: game_menu_panel.visible = false
	action_panel.visible = false
	carousel_view.visible = true
	
	_build_progress_dots()
	_display_current_page()

## ⚙️ Función especial para abrir tu menú personalizado
func _open_game_menu() -> void:
	_current_lesson = {} # Limpiamos la lección activa
	
	# Ocultamos toda la zona del carrusel, navegación y objetivos
	carousel_view.visible = false
	action_panel.visible = false
	$MarginContainer/HBoxContainer/RightContentArea/CarouselNavigation.visible = false
	
	# Mostramos tu panel con tus botones personalizados de juego
	if game_menu_panel:
		game_menu_panel.visible = true
	else:
		push_error("TutorialPopup: No se configuró el nodo 'GameMenuPanel' en la derecha.")

## ⚪ Genera las bolitas
func _build_progress_dots() -> void:
	for child in dots_container.get_children():
		child.queue_free()
		
	var pages: Array = _current_lesson.get("pages", [])
	if _current_lesson.is_empty() or pages.is_empty(): return
	
	for i in range(pages.size()):
		var dot: Panel = _dot_template.duplicate() if _dot_template else Panel.new()
		dots_container.add_child(dot)

## 📺 Renderiza datos
func _display_current_page() -> void:
	# Nos aseguramos de que la barra de navegación vuelva a ser visible por si veníamos del menú general
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
	next_page_button.text = "Ver Objetivos" if _current_page_index == pages.size() - 1 else ">"
	
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
		_show_objectives_screen()

func _show_objectives_screen() -> void:
	carousel_view.visible = false
	action_panel.visible = true
	
	for child in objectives_list.get_children():
		child.queue_free()
		
	var objectives: Array = _current_lesson.get("objectives", [])
	for objective_text in objectives:
		var check_box: CheckBox = _checkbox_template.duplicate() if _checkbox_template else CheckBox.new()
		check_box.text = str(objective_text)
		check_box.disabled = true
		objectives_list.add_child(check_box)
