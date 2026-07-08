extends Node
class_name ShopComponent

signal shop_opened
signal shop_closed

var is_shop_visible: bool = false

func _ready() -> void:
	add_to_group("shop_component")
	if has_node("/root/EventBus"):
		EventBus.server_purchase_requested.connect(_on_purchase_intent)
		EventBus.building_canceled.connect(_on_building_canceled)

func toggle_shop(force_state: Variant = null) -> void:
	if force_state != null:
		is_shop_visible = force_state
	else:
		is_shop_visible = !is_shop_visible
	
	if is_shop_visible:
		shop_opened.emit()
	else:
		shop_closed.emit()

func buy_item(category: String, subcategory: String) -> void:
	if not ItemDatabase.ITEMS.has(category) or not ItemDatabase.ITEMS[category].has(subcategory):
		push_error("ShopComponent: Claves de catálogo inválidas: " + category + " -> " + subcategory)
		return
		
	# ⚡ MODIFICACIÓN CRÍTICA: Duplicamos para inyectar datos de rastreo sin corromper la DB estática
	var item_data: Dictionary = ItemDatabase.ITEMS[category][subcategory].duplicate()
	item_data["category"] = category
	item_data["subcategory"] = subcategory
	
	var current_money: int = DataManager.current_save.money

	if current_money < item_data["cost"]:
		if has_node("/root/ToastManager"):
			ToastManager.show_toast("Fondos insuficientes para: " + item_data["name"], "ATAQUE")
		return

	DataManager.current_save.money -= item_data["cost"]
	toggle_shop(false)
	
	if has_node("/root/EventBus"):
		EventBus.item_purchased_successfully.emit(item_data)
		EventBus.start_building_mode.emit(item_data)
		
	if has_node("/root/ToastManager"):
		ToastManager.show_toast("Procesando compra... " + item_data["name"], "INFO")

func _on_building_canceled(cost: int, item_name: String) -> void:
	DataManager.current_save.money += cost
	if has_node("/root/ToastManager"):
		ToastManager.show_toast("❌ Construcción cancelada. Reembolsado: $" + str(cost), "ATAQUE")

func _on_purchase_intent() -> void:
	buy_item("SERVIDORES", "GAMA_MUY_BAJA")
