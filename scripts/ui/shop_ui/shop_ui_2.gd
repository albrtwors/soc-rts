extends PanelContainer
class_name ShopUI

# 📦 Escena de la tarjeta
@export var item_row_scene: PackedScene 

# 🔍 Referencias del Árbol de Nodos
@onready var tabs_container: HBoxContainer = $MarginContainer/VBoxContainer/PagingTabs
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

var current_category: String = "SERVIDORES"

func _ready() -> void:
	visible = false
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		
	if has_node("/root/EventBus"):
		EventBus.force_close_game_interfaces.connect(_on_force_close_requested)
		
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	if shop_component:
		shop_component.shop_opened.connect(_on_shop_opened)
		shop_component.shop_closed.connect(_on_shop_closed)

func _on_shop_opened() -> void:
	visible = true  # ⚡ VISIBILIDAD INMEDIATA: Corrige el bug de doble pulsación
	
	# ⚡ EVALUACIÓN CONTEXTUAL STRICTA: Pasamos la acción al árbitro central sin duplicaciones
	if has_node("/root/EventBus") and EventBus.is_in_tutorial:
		var tutorial_component = get_tree().get_first_node_in_group("tutorial_component") as TutorialComponent
		if tutorial_component and tutorial_component.is_active:
			if tutorial_component.current_lesson_id == "the_shop":
				EventBus.tutorial_step_advanced.emit("shop")
			elif tutorial_component.current_lesson_id == "constructing_lesson":
				EventBus.tutorial_step_advanced.emit("open_shop_build")
				
	_build_category_tabs()
	_render_catalog(current_category)

func _on_shop_closed() -> void:
	visible = false

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

func _render_catalog(category: String) -> void:
	for child in grid_container.get_children():
		child.queue_free()
		
	if not ItemDatabase.ITEMS.has(category):
		push_warning("ShopUI: Categoría inválida '" + category + "'")
		return
		
	var category_items: Dictionary = ItemDatabase.ITEMS[category]
	
	for subcategory in category_items.keys():
		var item_data: Dictionary = category_items[subcategory]
		if not item_row_scene: return
			
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
		
func _on_force_close_requested() -> void:
	if visible:
		visible = false
