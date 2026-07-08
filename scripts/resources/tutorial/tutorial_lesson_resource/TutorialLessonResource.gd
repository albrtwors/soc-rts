extends Resource
class_name TutorialLessonResource

@export var lesson_id: String = ""
@export var lesson_name: String = "Nueva Lección"

@export_group("Páginas del Carrusel")
## Lista de diccionarios o sub-recursos. Para mantenerlo simple, usaremos un Array de diccionarios estructurados:
## [{ "title": "...", "description": "...", "image": Texture2D }]
@export var pages: Array[Dictionary] = []

@export_group("Fase de Objetivos")
## Lista de strings con los objetivos técnicos que se listarán al final (ej: "Abrir la Tienda")
@export var objectives: Array[String] = []
