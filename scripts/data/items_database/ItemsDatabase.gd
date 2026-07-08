# ItemDatabase.gd
class_name ItemDatabase

const ITEMS = {
	"SERVIDORES": {
		"GAMA_MUY_BAJA": {
			"id": "srv_muy_bajo",
			"name": "Raspberry Lab-Server",
			"cost": 150,
			"description": "Un nodo básico para pruebas de red locales. Capacidad de procesamiento mínima.",
			"protection_level": 5,
			"production_level": 2,
			"icon_path": "res://assets/ui/shop/servers/srv_muy_bajo.png",
			"3d_model_prev": "res://scenes/hardware/server_rack/server_rack_preview/server_rack_preview.tscn",
			"3d_model": "res://scenes/hardware/server_rack/server_rack.tscn",
			"3d_model_wrong": "res://scenes/hardware/server_rack/server_rack_preview_error/server_rack_preview_error.tscn"
		},
		"GAMA_BAJA": {
			"id": "srv_bajo",
			"name": "Micro-Tower Server v1",
			"cost": 500,
			"description": "Servidor reacondicionado. Ideal para levantar tus primeros servicios de logs.",
			"protection_level": 15,
			"production_level": 8,
			"icon_path": "res://assets/ui/shop/servers/srv_muy_bajo.png",
			"3d_model_prev": "res://scenes/hardware/server_rack/server_rack_preview/server_rack_preview.tscn",
			"3d_model": "res://scenes/hardware/server_rack/server_rack.tscn",
			"3d_model_wrong": "res://scenes/hardware/server_rack/server_rack_preview_error/server_rack_preview_error.tscn"

		},
		"GAMA_MEDIA": {
			"id": "srv_medio",
			"name": "ProLiant Quad-Core",
			"cost": 1500,
			"description": "Balance óptimo entre cómputo y consumo. Soporta firewalls intermedios.",
			"protection_level": 45,
			"production_level": 25,
			"icon_path": "res://assets/ui/shop/servers/srv_muy_bajo.png",

		},
		"GAMA_ALTA": {
			"id": "srv_alta",
			"name": "Quantum-SOC Blade Center",
			"cost": 5000,
			"description": "Infraestructura empresarial de alto rendimiento para mitigar ataques APT masivos.",
			"protection_level": 120,
			"production_level": 100,
			"icon_path": "res://assets/ui/shop/servers/srv_muy_bajo.png",

		}
	},
	"IMPRESORAS": {
		"OFICINA": {
			"id": "prn_laser",
			"name": "Impresora Láser de Red",
			"cost": 300,
			"description": "Genera reportes físicos de incidentes. Vulnerable a ataques de firmware.",
			"revenue_per_minute": 10,
			"icon_path": "res://assets/textures/items/prn_laser.png",
"3d_model_prev": "res://scenes/hardware/server_rack/server_rack_preview/server_rack_preview.tscn",
			"3d_model": "res://scenes/hardware/server_rack/server_rack.tscn",
			"3d_model_wrong": "res://scenes/hardware/server_rack/server_rack_preview_error/server_rack_preview_error.tscn"
		}
	}
}
