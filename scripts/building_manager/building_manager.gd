extends Node3D
class_name BuildingManager

@export_category("Escenas de Construcción")
@export var server_preview_scene: PackedScene ## El holograma normal (Shader Cyan/Verde)
@export var server_error_scene: PackedScene   ## El holograma de error (Shader Rojo)
@export var server_real_scene: PackedScene    ## El modelo del servidor real funcional

@export_category("Configuración del Grid")
@export var grid_size: float = 2.0            ## El tamaño de tus casillas (2x2 metros)
@export_flags_3d_physics var collision_mask: int = 2 ## Capa de colisión (Debe ser la Capa 2)

var _is_building: bool = false
var _preview_instance: Node3D
var _camera: Camera3D
var _movement_component: MovementComponent
var _can_place_here: bool = false

# Nos ayuda a saber cuál escena está visible actualmente para no re-instanciar innecesariamente
var _showing_error_mesh: bool = false

func _ready() -> void:
	_camera = get_tree().get_first_node_in_group("Camera")
	var player = get_tree().get_first_node_in_group("Player")
	if player and "movement_component" in player:
		_movement_component = player.movement_component
		
	EventBus.server_purchase_requested.connect(start_building_mode)

func start_building_mode() -> void:
	if _is_building: return
	
	if not _camera:
		_camera = get_tree().get_first_node_in_group("Camera")
	
	_is_building = true
	EventBus.is_building = true 
	_showing_error_mesh = false
	
	if _movement_component:
		_movement_component.is_moving_to_target = false
	
	# Inicializamos con el holograma normal (Cyan)
	_swap_preview_mesh(server_preview_scene)

func _cancel_building() -> void:
	_is_building = false
	EventBus.is_building = false 
	_can_place_here = false
	if _preview_instance:
		_preview_instance.queue_free()
		_preview_instance = null
		
func _process(_delta: float) -> void:
	if not _is_building or not _preview_instance: return
	
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_data := _get_raycast_collision_data(mouse_pos)
	
	# --- CASO 1: El mouse está sobre una zona física válida (Capa 2) ---
	if not ray_data.is_empty():
		var collider: Object = ray_data.collider
		var collision_point: Vector3 = ray_data.position
		
		if collider is Node and collider.is_in_group("ConstructableGround"):
			# Snapping exacto en el grid
			var snapped_x = round(collision_point.x / grid_size) * grid_size
			var snapped_z = round(collision_point.z / grid_size) * grid_size
			var target_position = Vector3(snapped_x, 0.0, snapped_z)
			
			# 🚫 NUEVO: Validación de Casilla Ocupada
			if _is_cell_occupied(target_position):
				_can_place_here = false
				if not _showing_error_mesh:
					_showing_error_mesh = true
					_swap_preview_mesh(server_error_scene)
				_preview_instance.global_position = target_position
				return # Salimos temprano; la casilla tiene un servidor
			
			# Si la casilla está libre y veníamos de estar en rojo, cambiamos al holograma cyan normal
			_can_place_here = true
			if _showing_error_mesh:
				_showing_error_mesh = false
				_swap_preview_mesh(server_preview_scene)
			
			_preview_instance.global_position = target_position
			return 
			
	# --- CASO 2: Zona prohibida o vacío ---
	_can_place_here = false
	
	# Si estábamos en cyan, cambiamos al holograma rojo de error
	if not _showing_error_mesh:
		_showing_error_mesh = true
		_swap_preview_mesh(server_error_scene)
	
	# Sigue al mouse de forma fluida usando la proyección matemática
	var fallback_position := _get_mouse_fallback_position(mouse_pos)
	_preview_instance.global_position = fallback_position

func _input(event: InputEvent) -> void:
	if not _is_building: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _can_place_here:
			_place_server()
		else:
			# 🚫 NUEVO: Mensaje dinámico si el error es por solapamiento o zona prohibida
			var current_pos = _preview_instance.global_position
			if _is_cell_occupied(current_pos):
				ToastManager.show_toast("❌ Espacio ocupado por otro rack.", "ATAQUE", 2.0)
			else:
				ToastManager.show_toast("❌ No puedes instalar infraestructura aquí.", "ATAQUE", 2.0)
			
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed) or event.is_action_pressed("ui_cancel"):
		_cancel_building()

func _place_server() -> void:
	if not server_real_scene: return
	
	var real_server := server_real_scene.instantiate() as Node3D
	var level_container = get_tree().get_first_node_in_group("LevelContainer")
	if level_container:
		level_container.add_child(real_server)
	else:
		get_tree().current_scene.add_child(real_server)
		
	real_server.global_position = _preview_instance.global_position
	real_server.add_to_group("ServidoresInstalados")
	
	ToastManager.show_toast("🛡️ Servidor Rack conectado a la red local.", "MITIGACION")
	_cancel_building()

## 🔄 FUNCIÓN CLAVE: Borra el holograma anterior e instancia el nuevo manteniendo la posición
func _swap_preview_mesh(new_scene: PackedScene) -> void:
	if not new_scene:
		push_error("BuildingManager: Falta asignar una de las escenas de preview en el Inspector.")
		return
		
	var old_position := Vector3.ZERO
	if _preview_instance:
		old_position = _preview_instance.global_position
		_preview_instance.queue_free()
		
	_preview_instance = new_scene.instantiate()
	add_child(_preview_instance)
	_preview_instance.global_position = old_position

## 🚫 NUEVO: Comprueba si algún servidor ya instalado comparte la misma coordenada del Grid
func _is_cell_occupied(target_pos: Vector3) -> bool:
	var installed_servers = get_tree().get_nodes_in_group("ServidoresInstalados")
	for server in installed_servers:
		if server is Node3D:
			# Comparamos X y Z ignorando pequeñas variaciones de altura (Y)
			# Usamos un margen de error pequeño (0.1) por si flotan un poquito
			if abs(server.global_position.x - target_pos.x) < 0.1 and abs(server.global_position.z - target_pos.z) < 0.1:
				return true
	return false

func _get_raycast_collision_data(mouse_pos: Vector2) -> Dictionary:
	if not _camera: return {}
	var space_state := get_world_3d().direct_space_state
	var ray_origin := _camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + _camera.project_ray_normal(mouse_pos) * 2000.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end, collision_mask)
	return space_state.intersect_ray(query)

func _get_mouse_fallback_position(mouse_pos: Vector2) -> Vector3:
	if not _camera: return Vector3.ZERO
	var ray_origin := _camera.project_ray_origin(mouse_pos)
	var ray_dir := _camera.project_ray_normal(mouse_pos)
	if ray_dir.y == 0: return Vector3.ZERO
	var t := -ray_origin.y / ray_dir.y
	return ray_origin + ray_dir * t
