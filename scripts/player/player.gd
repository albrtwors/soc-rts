extends Node3D
class_name Player

@export var camera: Camera3D

@onready var movement_component: MovementComponent = $MovementComponent
@onready var ui_component: UIComponent = $UI_Canvas/UIComponent

func _ready() -> void:
	# Verificación de seguridad en tiempo de ejecución
	if not camera:
		push_error("¡Player: No se ha asignado una Camera3D en el inspector!")
		return
	add_to_group('Player')
	
	if DataManager.current_save:
		global_position = DataManager.current_save.player_position
	# Inicializamos los componentes y les inyectamos las dependencias
	movement_component.setup(self, camera)
	ui_component.setup(self)
	
	# Ejemplo de inicialización: Mandamos una alerta de bienvenida a la UI
	ui_component.show_security_alert("Sistemas inicializados. Monitoreando red...", "INFO")
