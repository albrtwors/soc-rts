extends Node3D
class_name BuildingManager

@export_category("Configuración del Grid")
@export var grid_size: float = 2.0
@export_flags_3d_physics var collision_mask: int = 3

var _is_building: bool = false
var _is_demolishing: bool = false 

var _preview_instance: Node3D
var _camera: Camera3D
var _movement_component: MovementComponent
var _can_place_here: bool = false
var _showing_error_mesh: bool = false

var _current_preview_scene: PackedScene
var _current_error_scene: PackedScene
var _current_real_scene: PackedScene

var _current_item_cost: int = 0
var _current_item_name: String = ""
var _current_category: String = ""
var _current_subcategory: String = ""
var _current_item_data: Dictionary = {}

func _ready() -> void:
	_camera = get_tree().get_first_node_in_group("Camera")
	var player = get_tree().get_first_node_in_group("Player")
	if player and "movement_component" in player:
		_movement_component = player.movement_component
		
	if has_node("/root/EventBus"):
		EventBus.start_building_mode.connect(start_building_mode)
		EventBus.start_demolition_mode.connect(start_demolition_mode)

func start_building_mode(item_data: Dictionary) -> void:
	if _is_demolishing: _exit_all_modes()
	if _is_building: _cancel_building()
	
	if not _camera:
		_camera = get_tree().get_first_node_in_group("Camera")
	
	_current_item_data = item_data
	_current_category = item_data.get("category", "SERVIDORES")
	_current_subcategory = item_data.get("subcategory", "")
	_current_item_cost = item_data.get("cost", 0)
	_current_item_name = item_data.get("name", "Item")

	var prev_path = item_data.get("3d_model_prev", "res://scenes/hardware/server_rack/server_rack_preview/server_rack_preview.tscn")
	var wrong_path = item_data.get("3d_model_wrong", "res://scenes/hardware/server_rack/server_rack_preview_error/server_rack_preview_error.tscn")
	var real_path = item_data.get("3d_model", "res://scenes/hardware/server_rack/server_rack.tscn")
	
	if prev_path == "" or wrong_path == "" or real_path == "": return
		
	_current_preview_scene = load(prev_path)
	_current_error_scene = load(wrong_path)
	_current_real_scene = load(real_path)
	
	_is_building = true
	EventBus.is_building = true 
	_showing_error_mesh = false
	
	if _movement_component:
		_movement_component.is_moving_to_target = false
	
	_swap_preview_mesh(_current_preview_scene)

	# ⚡ FILTRADO SEGURO: Se notifica la interacción con la carpeta/cuadrícula
	if has_node("/root/EventBus") and EventBus.is_in_tutorial:
		var tutorial_component = get_tree().get_first_node_in_group("tutorial_component") as TutorialComponent
		if tutorial_component and tutorial_component.current_lesson_id == "constructing_lesson":
			EventBus.tutorial_step_advanced.emit("preview_started")

func start_demolition_mode() -> void:
	_exit_all_modes()
	_is_demolishing = true
	EventBus.is_building = true 
	if _movement_component:
		_movement_component.is_moving_to_target = false
	ToastManager.show_toast("🪓 Modo Demolición Activo.", "ATAQUE")

func _exit_all_modes() -> void:
	_cancel_building()
	_is_demolishing = false
	EventBus.is_building = false

func _cancel_building() -> void:
	_is_building = false
	_can_place_here = false
	if _preview_instance:
		_preview_instance.queue_free()
		_preview_instance = null
		
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed) or event.is_action_pressed("ui_cancel"):
		if _is_building:
			var cost_to_refund = _current_item_cost
			var name_to_refund = _current_item_name
			_cancel_building()
			EventBus.is_building = false 
			EventBus.building_canceled.emit(cost_to_refund, name_to_refund)
		elif _is_demolishing:
			_exit_all_modes()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _is_building and _can_place_here:
			_place_structure()

func _place_structure() -> void:
	if not _current_real_scene: return
	
	var real_node := _current_real_scene.instantiate() as Node3D
	var level_container = get_tree().get_first_node_in_group("LevelContainer")
	if level_container:
		level_container.add_child(real_node)
	else:
		get_tree().current_scene.add_child(real_node)
		
	real_node.global_position = _preview_instance.global_position
	real_node.add_to_group("InfraestructuraInstalada")
	
	if real_node is PlacedStructure:
		real_node.setup_structure(_current_category, _current_subcategory, _current_item_data)

	# ⚡ FILTRADO SEGURO DE INSTALACIÓN
	if has_node("/root/EventBus") and _current_category == "SERVIDORES":
		EventBus.tutorial_step_advanced.emit("install_server")
		
	ToastManager.show_toast("🛡️ " + _current_item_name + " operativo.", "MITIGACION")
	_cancel_building()
	EventBus.is_building = false 

func _process(_delta: float) -> void:
	if not _is_building or not _preview_instance: return
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_data := _get_raycast_collision_data(mouse_pos, 2)
	
	if not ray_data.is_empty():
		var collider: Object = ray_data.collider
		var collision_point: Vector3 = ray_data.position
		
		if collider is Node and collider.is_in_group("ConstructableGround"):
			var snapped_x = round(collision_point.x / grid_size) * grid_size
			var snapped_z = round(collision_point.z / grid_size) * grid_size
			var target_position = Vector3(snapped_x, 0.0, snapped_z)
			
			if _is_cell_occupied(target_position):
				_can_place_here = false
				if not _showing_error_mesh:
					_showing_error_mesh = true
					_swap_preview_mesh(_current_error_scene)
				_preview_instance.global_position = target_position
				return
			
			_can_place_here = true
			if _showing_error_mesh:
				_showing_error_mesh = false
				_swap_preview_mesh(_current_preview_scene)
			_preview_instance.global_position = target_position
			return 
			
	_can_place_here = false
	if not _showing_error_mesh:
		_showing_error_mesh = true
		_swap_preview_mesh(_current_error_scene)
	_preview_instance.global_position = _get_mouse_fallback_position(mouse_pos)

func _swap_preview_mesh(new_scene: PackedScene) -> void:
	if not new_scene: return
	var old_position := Vector3.ZERO
	if _preview_instance:
		old_position = _preview_instance.global_position
		_preview_instance.queue_free()
	_preview_instance = new_scene.instantiate()
	add_child(_preview_instance)
	_preview_instance.global_position = old_position

func _is_cell_occupied(target_pos: Vector3) -> bool:
	for item in get_tree().get_nodes_in_group("InfraestructuraInstalada"):
		if item is Node3D and abs(item.global_position.x - target_pos.x) < 0.1 and abs(item.global_position.z - target_pos.z) < 0.1:
			return true
	return false

func _get_raycast_collision_data(mouse_pos: Vector2, custom_mask: int = collision_mask) -> Dictionary:
	if not _camera: return {}
	var space_state := get_world_3d().direct_space_state
	var ray_origin := _camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + _camera.project_ray_normal(mouse_pos) * 2000.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end, custom_mask)
	return space_state.intersect_ray(query)

func _get_mouse_fallback_position(mouse_pos: Vector2) -> Vector3:
	if not _camera: return Vector3.ZERO
	var ray_origin := _camera.project_ray_origin(mouse_pos)
	var ray_dir := _camera.project_ray_normal(mouse_pos)
	if ray_dir.y == 0: return Vector3.ZERO
	var t := -ray_origin.y / ray_dir.y
	return ray_origin + ray_dir * t
