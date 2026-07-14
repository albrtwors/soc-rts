extends Node
class_name ConstructingLesson

var hud: TutorialHUD
var is_active: bool = false

func start_lesson(parent_hud: TutorialHUD) -> void:
	hud = parent_hud
	is_active = true
	hud.lesson_instruction_label.text = "Haz click en el carrito para abrir la tienda"

func handle_objective_progress(objective_key: String) -> void:
	if not is_active: return
	
	match objective_key:
		"open_shop_build":
			hud.lesson_instruction_label.text = "Compra tu primer servidor en el catálogo"
			
		"preview_started":
			hud.lesson_instruction_label.text = "Haz click en la cuadrícula de la carpeta para instalarlo"
			
		"install_server":
			is_active = false
			hud.lesson_instruction_label.text = "¡Excelente! Servidor energizado."

func stop_lesson() -> void:
	is_active = false
