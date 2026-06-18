extends Node3D
class_name MovementComponent

@export_category("Configuración de Movimiento")
@export var move_speed: float = 20.0
@export var collision_mask: int = 1

@export_category("Configuración de Inercia / Drag")
@export var drag_sensitivity: float = 0.15   ## Qué tan rápido responde al arrastre inicial
@export_range(0.0, 1.0) var friction: float = 0.1 ## Qué tan rápido se frena (valores más bajos = más resbaladizo/más momentum)

@export_category("Configuración de Zoom")
@export var zoom_speed: float = 0.1       
@export var min_zoom_factor: float = 0.3   
@export_range(1.0, 5.0) var max_zoom_factor: float = 2.5   

var player_root: Node3D
var camera: Camera3D

var target_position: Vector3
var is_moving_to_target: bool = false
var is_dragging: bool = false
var click_start_position: Vector2
var drag_threshold: float = 5.0

# Variables para controlar el Momentum
var _drag_velocity: Vector3 = Vector3.ZERO
var _camera_initial_offset: Vector3
var _current_zoom_factor: float = 1.0

func setup(p_root: Node3D, p_camera: Camera3D) -> void:
	player_root = p_root
	camera = p_camera
	target_position = player_root.global_position
	_camera_initial_offset = camera.position

func _input(event: InputEvent) -> void:
	# --- 1. DETECCIÓN DE ZOOM (Siempre disponible) ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			process_camera_zoom(-zoom_speed) 
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			process_camera_zoom(zoom_speed)  
			
	if event.is_action_pressed("ui_accept"):
		EventBus.server_purchase_requested.emit()
		
	# 🔴 INTERRUPTOR DE SEGURIDAD
	if EventBus.is_building: 
		is_dragging = false 
		_drag_velocity = Vector3.ZERO # Cancelamos la inercia si entra en modo construcción
		return

	# --- 2. CAPTURA DE CLICKS (ARRASTRE O VIAJE) ---
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.button_index == MOUSE_BUTTON_LEFT:
		if mouse_button.pressed:
			is_dragging = true
			click_start_position = mouse_button.position
			_drag_velocity = Vector3.ZERO # Detiene cualquier inercia previa al volver a hacer clic
		else:
			is_dragging = false
			var click_dist := click_start_position.distance_to(mouse_button.position)
			if click_dist < drag_threshold:
				get_click_3d_position(mouse_button.position)

	# --- 3. PROCESAMIENTO DE ARRASTRE ---
	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion and is_dragging:
		is_moving_to_target = false
		calculate_drag_momentum(mouse_motion.relative)

func _process(delta: float) -> void:
	if not player_root: return
	
	# --- SISTEMA DE INERCIA (MOMENTUM) ---
	if _drag_velocity.length() > 0.01:
		player_root.global_translate(_drag_velocity * delta)
		# Aplicamos la fricción usando lerp para desacelerar suavemente en cada frame
		_drag_velocity = _drag_velocity.lerp(Vector3.ZERO, friction * 60.0 * delta)
	else:
		_drag_velocity = Vector3.ZERO
		
	# --- MOVIMIENTO POR CLICK ---
	if is_moving_to_target:
		var current_pos := player_root.global_position
		var real_target := Vector3(target_position.x, current_pos.y, target_position.z)
		var next_pos := current_pos.move_toward(real_target, move_speed * delta)
		player_root.global_position = next_pos
		
		if current_pos.distance_to(real_target) < 0.1:
			is_moving_to_target = false

## En lugar de mover directamente, inyectamos velocidad acumulada
func calculate_drag_momentum(relative_motion: Vector2) -> void:
	# Ajustamos el vector de movimiento según la orientación típica del plano en Tycoons
	# Multiplicamos por la sensibilidad actual y el zoom para que el drag sea intuitivo
	var speed_multiplier = drag_sensitivity * _current_zoom_factor
	var target_velocity = Vector3(-relative_motion.x, 0, -relative_motion.y) * speed_multiplier
	
	# Hacemos un lerp rápido hacia la nueva velocidad para suavizar los cambios bruscos de la mano
	_drag_velocity = _drag_velocity.lerp(target_velocity, 0.3)

func process_camera_zoom(amount: float) -> void:
	if not camera: return
	_current_zoom_factor = clamp(_current_zoom_factor + amount, min_zoom_factor, max_zoom_factor)
	camera.position = _camera_initial_offset * _current_zoom_factor

func get_click_3d_position(mouse_pos: Vector2) -> void:
	if not camera or not player_root: return
	var space_state := player_root.get_world_3d().direct_space_state
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 2000.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end, collision_mask)
	var result := space_state.intersect_ray(query)
	
	if not result.is_empty():
		target_position = result.position
		is_moving_to_target = true
