extends PanelContainer
class_name ShopItemRow

signal purchase_requested(category: String, subcategory: String)

# 🔍 Rutas ajustadas (Asegúrate de añadir el TextureRect en tu escena si usas imágenes)
@onready var icon_rect: TextureRect = $MarginContainer/HBoxContainer/IconTextureRect
@onready var name_label: Label = $MarginContainer/HBoxContainer/TextContainer/NameLabel
@onready var stats_label: Label = $MarginContainer/HBoxContainer/TextContainer/StatsLabel
@onready var desc_label: Label = $MarginContainer/HBoxContainer/TextContainer/DescLabel
@onready var buy_button: Button = $MarginContainer/HBoxContainer/ActionContainer/BuyButton

var _category: String
var _subcategory: String

func setup_card(category: String, subcategory: String, item_data: Dictionary) -> void:
	_category = category
	_subcategory = subcategory
	
	if name_label: 
		name_label.text = item_data.get("name", "Dispositivo SOC")
	if desc_label: 
		desc_label.text = item_data.get("description", "Sin descripción de seguridad.")
	if buy_button: 
		buy_button.text = "Comprar por $" + str(item_data.get("cost", 0))
	
	# 🖼️ CONTROL DE LA IMAGEN TOON
	if icon_rect:
		var path = item_data.get("icon_path", "")
		if path != "" and ResourceLoader.exists(path):
			icon_rect.texture = load(path)
			icon_rect.visible = true
		else:
			# Si no hay imagen en la DB, puedes ocultar el slot para que el texto ocupe su lugar
			icon_rect.visible = false 

	# 📊 PROCESAMIENTO DINÁMICO DE ESTADÍSTICAS
	var stats_text: String = ""
	if item_data.has("protection_level"):
		stats_text += "🛡️ Protección: +" + str(item_data["protection_level"]) + " "
	if item_data.has("production_level"):
		stats_text += "⚙️ Rendimiento: +" + str(item_data["production_level"]) + " "
	if item_data.has("revenue_per_minute"):
		stats_text += "💵 Ingresos: +$" + str(item_data["revenue_per_minute"]) + "/min "
	if item_data.has("price"):
		stats_text += "(PRECIO):" + str(item_data.has("price"))
	if stats_text == "":
		stats_text = "Dispositivo Pasivo"
		
	if stats_label:
		stats_label.text = stats_text

	if buy_button and not buy_button.pressed.is_connected(_on_buy_pressed):
		buy_button.pressed.connect(_on_buy_pressed)

func _on_buy_pressed() -> void:
	purchase_requested.emit(_category, _subcategory)
