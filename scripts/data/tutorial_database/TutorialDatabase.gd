extends Node

# 📋 BASE DE DATOS ESTRUCTURADA PARA PROGRESIÓN DINÁMICA
const LESSONS = [
	{
		"id": "introduction_soc",
		"lesson_name": "01. Introducción al SOC",
		"requires_lesson": "", # Disponible desde el inicio
		"pages": [
			{
				"title": "Bienvenido Operador",
				"description": "Estás a cargo de la seguridad de la infraestructura. Tu objetivo es mitigar amenazas antes de que comprometan el núcleo.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			},
			{
				"title": "Expande tu laboratorio",
				"description": "Por ahora algunas zonas estarán restringidas, cuando tengas suficientes recursos ve a la tienda a adquirirlas!",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			"Reconocer los servidores principales",
			"Abrir la Tienda del SOC",
			"Adquirir un Servidor Gama Muy Baja"
		]
	},
	{
		"id": "the_shop",
		"lesson_name": "02. La Tienda",
		"requires_lesson": "introduction_soc", # Requiere completar la lección 1
		"pages": [
			{
				"title": "Comprar",
				"description": "La tienda estará disponible en todo momento, solo haz click en el botón y se abrirá la interfaz.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			},
			{
				"title": "Categorías",
				"description": "Algunos objetos serán mejoras, otros directamente podrás construirlos en tu infraestructura tecnológica.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			"Instalar una Impresora Láser"
		]
	},
	{
		"id": "traffic_printers",
		"lesson_name": "03. Tráfico e Impresoras",
		"requires_lesson": "the_shop", # Requiere completar la lección 2
		"pages": [
			{
				"title": "Reportes Físicos",
				"description": "Las impresoras generan reportes que aumentan tus ingresos por minuto, pero son vectores comunes de intrusión de firmware.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			"Recolectar reportes físicos impresos"
		]
	},
	{
		"id": "siem_monitoring",
		"lesson_name": "04. Monitoreo de Red (SIEM)",
		"requires_lesson": "traffic_printers",
		"pages": [
			{
				"title": "El Tablero Principal",
				"description": "Aquí verás el flujo de datos en tiempo real. Presta atención a los picos inusuales de tráfico; podrían indicar un escaneo de puertos.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			},
			{
				"title": "Logs de Eventos",
				"description": "Cada acción se registra. Filtrar los logs te permitirá aislar IPs sospechosas antes de que inicien una exfiltración.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			"Abrir la consola SIEM",
			"Identificar y bloquear una IP sospechosa"
		]
	},
	{
		"id": "alert_management",
		"lesson_name": "05. Gestión de Alertas",
		"requires_lesson": "siem_monitoring",
		"pages": [
			{
				"title": "Falsos Positivos",
				"description": "No todo el tráfico bloqueado es un ataque. Aprende a distinguir entre un empleado olvidando su contraseña y un ataque de fuerza bruta.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			},
			{
				"title": "Severidad del Incidente",
				"description": "Clasifica las alertas en Baja, Media y Alta para priorizar los recursos del SOC de manera eficiente.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			"Descartar 3 falsos positivos",
			"Resolver una alerta de severidad Alta"
		]
	},
	{
		"id": "mitigation_patching",
		"lesson_name": "06. Mitigación y Parcheo",
		"requires_lesson": "alert_management",
		"pages": [
			{
				"title": "Actualizaciones Críticas",
				"description": "Los atacantes explotarán vulnerabilidades conocidas. Mantén tus servidores y sistemas operativos actualizados desde el panel de control.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			"Actualizar el firmware del Servidor Gama Baja",
			"Desplegar un Firewall básico en la red"
		]
	}
]
