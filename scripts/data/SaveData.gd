extends Resource
class_name SaveData

@export_group("Perfil del Administrador")
@export var player_name: String = "Eminem"
@export var player_lastname: String = "Estudiante"
@export var player_age: int = 20
@export var player_pnf: String = "Informatica"
@export var player_role: String = "Novato"
@export var player_avatar_path: String = ""

@export_group("Economía y Recursos")
@export var money: float = 5000.0
@export var ram_capacity: int = 16

@export_group("Progreso del Laboratorio")
@export var servers: Dictionary = {}
@export var unlocked_tools: Array[String] = ["firewall_v1"]
@export var player_position: Vector3 = Vector3.ZERO
@export var is_tutorial_completed: bool = false

@export_group("Tutorial")
# ⚡ CORRECCIÓN CRÍTICA: Se añade @export para que ResourceSaver lo guarde físicamente
@export var completed_lessons: Array = []
