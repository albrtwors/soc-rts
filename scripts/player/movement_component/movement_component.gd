extends Node3D
class_name MovementComponent

@export_category("Configuración de Movimiento")
@export var move_speed: float = 20.0
@export var collision_mask: int = 1

@export_category("Configuración de Inercia / Drag")
@export var drag_sensitivity: float = 0.15
@export_range(0.0, 1.0) var friction: float = 0.1

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

var _drag_velocity: Vector3 = Vector3.ZERO
var _camera_initial_offset: Vector3
var _current_zoom_factor: float = 1.0

func setup(p_root: Node3D, p_camera: Camera3D) -> void:
	player_root = p_root
	camera = p_camera
	target_position = player_root.global_position
	_camera_initial_offset = camera.position

func _input(event: InputEvent) -> void:
	# 🛑 FILTRO CRÍTICO 1: Si el mouse está haciendo clic en un botón o elemento de interfaz,
	# cancelamos el procesamiento para que la cámara no se mueva por debajo.
	if get_viewport().gui_get_hovered_control() != null:
		if event is InputEventMouseButton and not event.pressed:
			is_dragging = false # Previene que el drag se quede pegado al soltar el clic sobre la UI
		return

	# 🛑 FILTRO CRÍTICO 2: Interruptor de seguridad para construcción o tutorial
	if EventBus.is_building or EventBus.is_in_tutorial: 
		is_dragging = false 
		_drag_velocity = Vector3.ZERO 
		# Permitimos el zoom incluso en modo construcción, quitando el return de aquí si deseas zoom siempre
		if not (event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN)):
			return

	# --- 1. DETECCIÓN DE ZOOM ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			process_camera_zoom(-zoom_speed) 
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			process_camera_zoom(zoom_speed)  

	# --- 2. CAPTURA DE CLICKS (ARRASTRE O VIAJE) ---
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.button_index == MOUSE_BUTTON_LEFT:
		if mouse_button.pressed:
			is_dragging = true
			click_start_position = mouse_button.position
			_drag_velocity = Vector3.ZERO
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
	
	if _drag_velocity.length() > 0.01:
		player_root.global_translate(_drag_velocity * delta)
		_drag_velocity = _drag_velocity.lerp(Vector3.ZERO, friction * 60.0 * delta)
	else:
		_drag_velocity = Vector3.ZERO
		
	if is_moving_to_target:
		var current_pos := player_root.global_position
		var real_target := Vector3(target_position.x, current_pos.y, target_position.z)
		var next_pos := current_pos.move_toward(real_target, move_speed * delta)
		player_root.global_position = next_pos
		
		if current_pos.distance_to(real_target) < 0.1:
			is_moving_to_target = false

func calculate_drag_momentum(relative_motion: Vector2) -> void:
	var speed_multiplier = drag_sensitivity * _current_zoom_factor
	var target_velocity = Vector3(-relative_motion.x, 0, -relative_motion.y) * speed_multiplier
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
