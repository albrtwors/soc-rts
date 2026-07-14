extends Control
class_name UIComponent

var player_root: Node3D

# --- 🎯 REFERENCIAS ASIGNADAS SEGÚN TU NUEVO ÁRBOL DE NODOS ---
@onready var name_label: Label = $"PlayerCard/Name Label"
@onready var role_label: Label = $"PlayerCard/Role Label"
@onready var player_pfp: TextureRect = $PlayerCard/PlayerPFP
@onready var time_label: Label = $"Date&HourCard/Name Label"
@onready var money_label: Label = $PnfAndMoney/Money
@onready var pnf_label: Label = $PnfAndMoney/Pnf
@onready var shop_button: Button = $ShopButton
@onready var destruction_button: Button = $DestructionButton
@onready var help_button: Button = $Ayuda # 👈 NUEVO BOTÓN "AYUDA" VINCULADO

func setup(p_root: Node3D) -> void:
	player_root = p_root

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	
	if shop_component:
		shop_button.pressed.connect(func(): shop_component.toggle_shop())
		
	destruction_button.pressed.connect(func(): EventBus.start_demolition_mode.emit())
	
	# ⚡ CONECTAMOS EL BOTÓN DE AYUDA PARA REABRIR EL TUTORIAL DE FORMA VOLUNTARIA
	if help_button:
		help_button.pressed.connect(_on_help_pressed)
		
	_initialize_player_profile()

func _process(_delta: float) -> void:
	_update_live_clock()
	pnf_label.text = "PNF: " + str(DataManager.current_save.player_pnf)
	money_label.text = "DINERO: " + str(DataManager.current_save.money)

## ⚡ Abre el popup para consultar o repasar cualquier lección
func _on_help_pressed() -> void:
	print("UIComponent: Consultando ayuda. Desplegando TutorialPopup.")
	if has_node("/root/EventBus"):
		EventBus.start_tutorial.emit()

func _update_live_clock() -> void:
	if not time_label: return
	
	var time_dict := Time.get_datetime_dict_from_system()
	var formatted_time := "%02d/%02d/%d %02d:%02d:%02d" % [
		time_dict.day,
		time_dict.month,
		time_dict.year,
		time_dict.hour,
		time_dict.minute,
		time_dict.second
	]
	
	time_label.text = formatted_time

func _initialize_player_profile() -> void:
	if not DataManager or not DataManager.current_save:
		push_error("UIComponent: No se detectó un archivo de guardado activo en el DataManager.")
		return
		
	var save_data: SaveData = DataManager.current_save
	print(save_data)
	if name_label:
		name_label.text = save_data.player_name
		
	if role_label:
		role_label.text = save_data.player_role
		
	if player_pfp and not save_data.player_avatar_path.is_empty():
		if FileAccess.file_exists(save_data.player_avatar_path):
			var image := Image.load_from_file(save_data.player_avatar_path)
			if image:
				var texture := ImageTexture.create_from_image(image)
				player_pfp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				player_pfp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				player_pfp.texture = texture
		else:
			print("UIComponent: La ruta de la foto no existe: ", save_data.player_avatar_path)

func update_stats(data: Dictionary) -> void:
	pass

func show_security_alert(message: String, severity: String = "INFO") -> void:
	match severity:
		"CRITICAL":
			print_rich("[color=red][b]¡ALERTA CRÍTICA![/b] %s[/color]" % message)
		"WARNING":
			print_rich("[color=yellow][b]ADVERTENCIA:[/b] %s[/color]" % message)
		_:
			print_rich("[color=cyan]INFO:[/color] %s" % message)

func toggle_window(window: Control) -> void:
	if not window: return
	window.visible = !window.visible
	if window.visible:
		window.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		window.mouse_filter = Control.MOUSE_FILTER_IGNORE

func clear_ui_focus() -> void:
	var focused_node := get_viewport().gui_get_focus_owner()
	if focused_node:
		focused_node.release_focus()
