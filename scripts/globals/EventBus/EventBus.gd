# EventBus.gd (Autoload Singleton)
extends Node

# Señales globales del ciclo de la Tienda y Construcción

### SHOP RELATED
signal server_purchase_requested
signal item_purchased_successfully(item_data: Dictionary)

### BUILDING RELATED
signal start_building_mode(item_data: Dictionary) # <-- Modificada para recibir el diccionario
signal building_canceled(cost: int, item_name: String) # <-- Nueva para devoluciones

signal start_demolition_mode
signal structure_demolished(refund_amount: int, item_name: String)

### Señales del Tutorial
signal tutorial_step_advanced
signal start_tutorial

### Flags de Control Global
var is_building: bool = false
var is_in_tutorial: bool = false
