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
signal cancel_current_tutorial()
signal force_close_game_interfaces
signal start_tutorial
signal lesson_selected(lesson_id: String)        # ⚡ NUEVA: UI -> Componente
signal tutorial_step_advanced(objective_key: String) # ⚡ MODIFICADA: Mapa -> Componente
signal objective_completed(objective_key: String)    # ⚡ NUEVA: Componente -> UI
var is_tutorial_popup_open: bool = false # ⚡ Controla si la interfaz teórica bloquea la pantalla



signal game_session_started(lesson_id: String) # ⚡ Nueva: Despacha el arranque del entorno 3D

### Flags de Control Global
var is_building: bool = false
var is_in_tutorial: bool = false


# En EventBus.gd:
