extends Node
# 🌍 AUTOLOAD GLOBAL: EventBus (Gestor central de eventos)

## Se emite desde la UI cuando el jugador compra un servidor rack estándar
signal server_purchase_requested
var is_building: bool = false
