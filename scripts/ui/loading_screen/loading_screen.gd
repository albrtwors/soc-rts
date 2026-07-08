extends Control
class_name LoadingScreenComponent

@onready var tips_label: Label = $TipsLabel
@onready var loading_label: Label = $LoadingLabel

var tips: Array[String] = [
	"Consejo del SOC: Los ataques de inyección Regex (ReDoS) pueden congelar tus servidores si usas patrones mal optimizados.",
	"Consejo del SOC: Mitiga los ataques de fuerza bruta implementando bloqueos temporales por IP (Rate Limiting).",
	"Consejo del SOC: Monitorea constantemente los logs de red. Un pico inusual de tráfico saliente puede significar exfiltración de datos.",
	"Consejo del SOC: Actualiza el firmware de tus routers e impresoras físicas. Todo dispositivo IoT es un vector de ataque potencial."
]

var _tips_timer: Tween
var _dots_timer: Tween
var _dot_count: int = 0

func _ready() -> void:
	visible = false # Empieza oculta por defecto

## Dispara la pantalla de carga
func start_loading() -> void:
	visible = true
	_show_random_tip()
	_start_dots_animation()
	
	# Ciclo de consejos cada 4 segundos usando tweens cíclicos limpios
	_tips_timer = create_tween().set_loops()
	_tips_timer.tween_callback(_show_random_tip).set_delay(4.0)

## Apaga la pantalla y limpia timers para evitar memory leaks
func stop_loading() -> void:
	visible = false
	if _tips_timer: _tips_timer.kill()
	if _dots_timer: _dots_timer.kill()

func _show_random_tip() -> void:
	if not tips.is_empty():
		tips_label.text = tips[randi() % tips.size()]

func _start_dots_animation() -> void:
	_dots_timer = create_tween().set_loops()
	_dots_timer.tween_callback(
		func():
			_dot_count = (_dot_count + 1) % 4
			# ⚡ CORRECCIÓN DE G4: Usamos '.repeat()' para duplicar el string de forma nativa
			var dots = ".".repeat(_dot_count)
			loading_label.text = "Cargando" + dots
	).set_delay(0.5)
