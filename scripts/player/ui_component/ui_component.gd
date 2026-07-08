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
func setup(p_root: Node3D) -> void:
	player_root = p_root

func _ready() -> void:
	# Nos aseguramos por código de que la raíz nunca bloquee los clicks del mapa 3D
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	
	if shop_component:
		shop_button.pressed.connect(func(): shop_component.toggle_shop())
		
	destruction_button.pressed.connect(func(): EventBus.start_demolition_mode.emit())
	
	# ⚡ Cargamos los datos del perfil guardados en la RAM al iniciar el juego
	_initialize_player_profile()
func _process(_delta: float) -> void:
	_update_live_clock()
	pnf_label.text="PNF: " + str(DataManager.current_save.player_pnf)
	money_label.text="DINERO: " + str(DataManager.current_save.money)

## 🕒 Captura la hora y fecha del sistema y la estampa en la interfaz
func _update_live_clock() -> void:
	if not time_label: return
	
	# Obtenemos un diccionario con la hora local real de la PC/dispositivo
	var time_dict := Time.get_datetime_dict_from_system()
	
	# Formateamos los datos para que queden limpios (DD/MM/AAAA HH:MM:SS)
	# %02d asegura que si el número es menor a 10, se le ponga un cero a la izquierda (ej: "05" en vez de "5")
	var formatted_time := "%02d/%02d/%d %02d:%02d:%02d" % [
		time_dict.day,
		time_dict.month,
		time_dict.year,
		time_dict.hour,
		time_dict.minute,
		time_dict.second
	]
	
	time_label.text = formatted_time
## Lee el recurso SaveData activo en el DataManager y rellena la UI
func _initialize_player_profile() -> void:
	
	# Verificamos que tengamos un guardado en memoria válido antes de leer
	if not DataManager or not DataManager.current_save:
		push_error("UIComponent: No se detectó un archivo de guardado activo en el DataManager.")
		return
		
	var save_data: SaveData = DataManager.current_save
	print(save_data)
	# 1. Asignamos los textos de identificación del SOC
	if name_label:
		name_label.text = save_data.player_name
		
	if role_label:
		role_label.text = save_data.player_role
		
	# 2. Procesamos el Avatar externo si el usuario subió una imagen
	if player_pfp and not save_data.player_avatar_path.is_empty():
		if FileAccess.file_exists(save_data.player_avatar_path):
			var image := Image.load_from_file(save_data.player_avatar_path)
			if image:
				var texture := ImageTexture.create_from_image(image)
				
				# 🛠️ Protegemos los límites y escalado cuadrado exacto en la tarjeta
				player_pfp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				player_pfp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				
				player_pfp.texture = texture
		else:
			print("UIComponent: La ruta de la foto no existe o el archivo original se movió: ", save_data.player_avatar_path)


# --- 🛠️ FUNCIONES ÚTILES POR DEFECTO ---

## 1. Gestión de Recursos / Estadísticas (CPU, RAM, Presupuesto, etc.)
func update_stats(data: Dictionary) -> void:
	pass

## 2. Sistema de Alertas de Intrusión (Popups o banners de Advertencia)
func show_security_alert(message: String, severity: String = "INFO") -> void:
	match severity:
		"CRITICAL":
			print_rich("[color=red][b]¡ALERTA CRÍTICA![/b] %s[/color]" % message)
		"WARNING":
			print_rich("[color=yellow][b]ADVERTENCIA:[/b] %s[/color]" % message)
		_:
			print_rich("[color=cyan]INFO:[/color] %s" % message)

## 3. Control de Menús Flotantes (Abrir/Cerrar Tienda de Servidores o Firewalls)
func toggle_window(window: Control) -> void:
	if not window: return
	
	window.visible = !window.visible
	
	if window.visible:
		window.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		window.mouse_filter = Control.MOUSE_FILTER_IGNORE

## 4. Limpiador de Selección
func clear_ui_focus() -> void:
	var focused_node := get_viewport().gui_get_focus_owner()
	if focused_node:
		focused_node.release_focus()
