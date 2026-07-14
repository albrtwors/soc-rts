extends PanelContainer
class_name ShopUI2

# 📦 Arrastra tu escena 'ShopItemRow.tscn' a esta casilla en el Inspector
@export var item_row_scene: PackedScene 

# 🔍 Rutas exactas a los nodos según tu árbol
@onready var grid_container: GridContainer = $VBoxContainer/GridContainer
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready() -> void:
	# La tienda inicia oculta en la terminal del SOC
	visible = false
	if has_node("/root/EventBus"):
		# ⚡ Escuchamos la orden de clausura del tutorial
		EventBus.force_close_game_interfaces.connect(_on_force_close_requested)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		
	# 🔌 Conexión reactiva al ShopComponent de Godot 4
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	if shop_component:
		shop_component.shop_opened.connect(_on_shop_opened)
		shop_component.shop_closed.connect(_on_shop_closed)
	
	# Renderizamos la categoría principal por defecto
	_render_catalog("SERVIDORES")

## Se ejecuta de forma automática cuando el componente avanza el estado de la tienda
func _on_shop_opened() -> void:
	visible = true

func _on_shop_closed() -> void:
	visible = false

## Limpia el contenedor e instancia las filas de forma dinámica usando el catálogo
func _render_catalog(category: String) -> void:
	# 1. Limpieza preventiva del Grid
	for child in grid_container.get_children():
		child.queue_free()
		
	if not ItemDatabase.ITEMS.has(category):
		push_warning("ShopUI: La categoría '" + category + "' no existe en la base de datos.")
		return
	
	var category_items: Dictionary = ItemDatabase.ITEMS[category]
	
	# 2. Iteramos sobre las gamas del diccionario (GAMA_MUY_BAJA, GAMA_BAJA, etc.)
	for subcategory in category_items.keys():
		var data: Dictionary = category_items[subcategory]
		
		if not item_row_scene:
			push_error("ShopUI: No has asignado el 'item_row_scene' en el Inspector.")
			return
			
		# Instanciamos la tarjeta pre-diseñada
		var row_instance = item_row_scene.instantiate() as ShopItemRow
		grid_container.add_child(row_instance)
		
		# Inyectamos la data estructural
		row_instance.setup(category, subcategory, data)
		
		# 🎯 CORRECCIÓN: Conectamos usando el nombre exacto de la señal del hijo
		row_instance.purchase_requested.connect(func(cat: String, subcat: String):
			var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
			if shop_component:
				shop_component.buy_item(cat, subcat)
		)

## Notifica al componente para cerrar la tienda y restablecer flags como 'is_building'
func _on_close_pressed() -> void:
	var shop_component = get_tree().get_first_node_in_group("shop_component") as ShopComponent
	if shop_component:
		shop_component.toggle_shop()
func _on_force_close_requested() -> void:
	if visible:
		visible = false
		print("ShopUI: Interfaz cerrada forzosamente por el sistema de tutoriales.")
