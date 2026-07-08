# PlacedStructure.gd
extends Node3D
class_name PlacedStructure

# 📊 Datos de negocio cargados dinámicamente desde la Base de Datos
var item_id: String = ""
var category: String = ""
var subcategory: String = ""
var structure_name: String = ""
var cost: int = 0
# Estadísticas operativas genéricas
var protection_level: int = 0
var production_level: int = 0
var revenue_per_minute: int = 0

## 📥 Inyección de dependencias en caliente
func setup_structure(cat: String, subcat: String, data: Dictionary) -> void:
	category = cat
	subcategory = subcat
	item_id = data.get("id", "")
	structure_name = data.get("name", "Infraestructura")
	cost = data.get("cost", 0)
	# Extraemos las estadísticas de forma segura (si no existen en ese ítem, quedan en 0)
	protection_level = data.get("protection_level", 0)
	production_level = data.get("production_level", 0)
	revenue_per_minute = data.get("revenue_per_minute", 0)
	
	print("⚙️ Estructura inicializada genéricamente: ", structure_name, " [", category, "]")
	
	# 💡 Aquí puedes activar lógica según el tipo si fuera necesario:
	if category == "IMPRESORAS":
		_setup_printer_logic()

func _setup_printer_logic() -> void:
	# Por ejemplo, iniciar un Timer que sume dinero cada minuto usando 'revenue_per_minute'
	pass

## 🛡️ Un solo método genérico para procesar ciberataques basados en sus stats
func recibir_ataque(fuerza: float) -> void:
	# El daño recibido podría mitigarse directamente con el 'protection_level' de este ítem
	var daño_real = max(0.0, fuerza - (protection_level * 0.1))
	print(structure_name, " recibió ", daño_real, " de daño neto.")
