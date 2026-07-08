extends Control
class_name CharacterCreationComponent

# 📡 Añadimos p_avatar_path a la señal (pasa la ruta como String)
signal profile_created(player_name: String, lastname: String, age: int, role: String, p_avatar_path: String, pnf: String)

# Referencias internas dentro de tu CustomizationBox
@onready var name_input: LineEdit = $CustomizationBox/UserInfoPanel/UserInfoRow/NameLIne
@onready var lastname_input: LineEdit = $CustomizationBox/UserInfoPanel/UserInfoRow/SurnameLine
@onready var age_input: SpinBox = $CustomizationBox/UserInfoPanel/UserInfoRow/AgeLine
@onready var role_input: OptionButton = $CustomizationBox/UserInfoPanel/UserInfoRow/OptionButton
@onready var pnf_input: OptionButton = $CustomizationBox/UserInfoPanel/UserInfoRow/OptionButtonPNF
# 🖼️ Referencias para el Avatar (PlayerPfpPanel)
@onready var pfp_texture: TextureRect = $CustomizationBox/PlayerPfpPanel/PlayerPfpRow/HBoxContainer/Pfp
@onready var upload_button: Button = $CustomizationBox/PlayerPfpPanel/PlayerPfpRow/UploadFileButton

@onready var continue_button: Button = $ContinueButton

# 📁 Nodo para abrir el explorador de archivos del sistema
var file_dialog: FileDialog
var current_avatar_path: String = ""

func _ready() -> void:
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
		
	if upload_button:
		upload_button.pressed.connect(_on_upload_button_pressed)
		
	_setup_file_dialog()

## Configura el explorador de archivos invisible listo para usarse
func _setup_file_dialog() -> void:
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	# Filtros para que solo te deje subir imágenes reales
	file_dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg, *.jpeg ; JPEG Images"])
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)

func _on_upload_button_pressed() -> void:
	# Abre la ventana emergente en el centro de la pantalla
	file_dialog.popup_centered_clamped(Vector2i(800, 600))

func _on_file_selected(path: String) -> void:
	current_avatar_path = path
	
	var image = Image.load_from_file(path)
	if image:
		var texture = ImageTexture.create_from_image(image)
		if pfp_texture:
			# 🛠️ CONTROL DE ESCALADO DE LA IMAGEN EXTERNA:
			
			# 1. Le permitimos ignorar el tamaño real del archivo original
			pfp_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			
			# 2. Mantenemos el aspecto (evita que el personaje se vea "estirado" o gordo)
			# y centramos la foto dentro del recuadro cyberpunk de tu UI
			pfp_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			
			# Asignamos la textura final
			pfp_texture.texture = texture
func _on_continue_pressed() -> void:
	var final_name: String = name_input.text.strip_edges() if name_input else "Eminem"
	var final_lastname: String = lastname_input.text.strip_edges() if lastname_input else "Estudiante"
	var final_age: int = int(age_input.value) if age_input else 20
	var final_role: String = "Novato"
	var final_pnf: String = "INFORMATICA"
	if role_input and role_input.selected != -1:
		final_role = role_input.get_item_text(role_input.selected)
	if pnf_input and pnf_input.selected!=-1:
		final_pnf = pnf_input.get_item_text(pnf_input.selected)
	if final_name.is_empty():
		ToastManager.show_toast("Debes asignar un nombre a tu administrador", "ATAQUE")
		return
		
	# Emitimos la señal incluyendo la ruta de la foto seleccionada
	profile_created.emit(final_name, final_lastname, final_age, final_role, current_avatar_path, final_pnf)
