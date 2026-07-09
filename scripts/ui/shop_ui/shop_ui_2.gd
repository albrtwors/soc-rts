extends PanelContainer
class_name ShopUI

# 📦 Escena de la tarjeta (debe aceptar setup con el nuevo diccionario completo)
@export var item_row_scene: PackedScene 

# 🔍 Referencias del Árbol de Nodos (Corregidas con MarginContainer)
@onready var tabs_container: HBoxContainer = $MarginContainer/VBoxContainer/PagingTabs
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

# Categoría activa por defecto para no arrancar en vacío
var current_category: String = "SERVIDORES"


func _ready() -> void:
	# La tienda inicia oculta
	visible = false
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		
	# Conexión al backend
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	if shop_component:
		shop_component.shop_opened.connect(_on_shop_opened)
		shop_component.shop_closed.connect(_on_shop_closed)

func _on_shop_opened() -> void:
	visible = true
	# ⚡ EJECUCIÓN CRUCIAL: Construimos la UI únicamente cuando ya es visible
	if has_node("/root/EventBus") and EventBus.is_in_tutorial:
		# Emitimos "shop" que coincide exactamente con el ID de tu base de datos
		EventBus.objective_completed.emit("shop")
		print("ShopUI: Se notificó la apertura de la tienda al EventBus.")
	_build_category_tabs()
	_render_catalog(current_category)

func _on_shop_closed() -> void:
	visible = false

## 📑 Genera dinámicamente botones superiores para cada categoría en la Database
func _build_category_tabs() -> void:
	for child in tabs_container.get_children():
		child.queue_free()
		
	for category in ItemDatabase.ITEMS.keys():
		var tab_button = Button.new()
		tab_button.text = category.capitalize()
		tab_button.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		tab_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		tab_button.pressed.connect(func():
			current_category = category
			_render_catalog(category)
		)
		tabs_container.add_child(tab_button)

## 🛒 Limpia, instancia y llena las tarjetas con la info de la base de datos
func _render_catalog(category: String) -> void:
	for child in grid_container.get_children():
		child.queue_free()
		
	if not ItemDatabase.ITEMS.has(category):
		push_warning("ShopUI: Categoría inválida '" + category + "'")
		return
		
	var category_items: Dictionary = ItemDatabase.ITEMS[category]
	
	for subcategory in category_items.keys():
		var item_data: Dictionary = category_items[subcategory]
		
		if not item_row_scene:
			push_error("ShopUI: Falta 'item_row_scene' en el Inspector.")
			return
			
		var card_instance = item_row_scene.instantiate() as ShopItemRow
		grid_container.add_child(card_instance)
		
		if card_instance.has_method("setup_card"):
			card_instance.setup_card(category, subcategory, item_data)
		
		card_instance.purchase_requested.connect(func(cat: String, subcat: String):
			var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
			if shop_component:
				shop_component.buy_item(cat, subcat)
				_render_catalog(current_category)
		)

func _on_close_pressed() -> void:
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	if shop_component:
		shop_component.toggle_shop()
