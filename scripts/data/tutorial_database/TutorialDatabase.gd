extends Node

# 📋 ÚNICA FUENTE DE VERDAD: Objetivos estructurados por ID + Texto de interfaz
const LESSONS = [
	{
		"id": "introduction_soc",
		"lesson_name": "01. Introducción al SOC",
		"hud_level": "Nivel: Movimiento",
		"hud_instruction": "Arrastra con Click Izquierdo para mover la cámara",
		"requires_lesson": "",
		"pages": [
			{
				"title": "Bienvenido Operador",
				"description": "Estás a cargo de la seguridad de la infraestructura. Tu objetivo es mitigar amenazas antes de que comprometan el núcleo.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			},    {
				"title": "Explorar el laboratorio",
				"description": "Comencemos por el movimiento. Para moverte basta con arrastrar el mouse con click izquierdo presionado",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			{"id": "moving", "text": "Reconocer los servidores principales"}
		]
	},
	{
		"id": "the_shop",
		"lesson_name": "02. La Tienda",
		"hud_level": "Nivel: Tienda",
		"hud_instruction": "Haz Click en el ícono de carro de compras para abrir la tienda",
		"requires_lesson": "introduction_soc",
		"pages": [
			{
				"title": "Tienda",
				"description": "La tienda estará disponible en todo momento. Para abrirla solo bastará con hacer click en el ícono del carro de compras",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			{"id": "shop", "text": "Abrir la tienda"}
		]
	},
	{
		"id": "constructing_lesson",
		"lesson_name": "03. Infraestructura",
		"hud_level": "Nivel: Construcción",
		"hud_instruction": "Haz click en el carrito para abrir la tienda",
		"requires_lesson": "the_shop",
		"pages": [
			{
				"title": "Expandiendo el Laboratorio",
				"description": "Para mitigar incidentes y procesar logs, tu SOC necesita hardware real. Vamos a comprar e instalar tu primer Servidor en una zona permitida.",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			{"id": "open_shop_build", "text": "Abrir la tienda de componentes"},
			{"id": "preview_started", "text": "Hacer click en la cuadrícula de la carpeta"},
			{"id": "install_server", "text": "Instalar el servidor en el suelo construible"}
		]
	},
	{
		"id": "siem_monitoring",
		"lesson_name": "04. Monitoreo de Red (SIEM)",
		"hud_level": "NIVEL 01",
		"hud_instruction": "Arrastra con Click Derecho para mover la cámara",
		"requires_lesson": "traffic_printers",
		"pages": [
			{
				"title": "El Tablero Principal",
				"description": "Aquí verás el flujo de datos...",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			{"id": "open_siem", "text": "Abrir la consola SIEM"},
			{"id": "block_ip", "text": "Identificar y bloquear una IP sospechosa"}
		]
	},
	{
		"id": "alert_management",
		"lesson_name": "05. Gestión de Alertas",
		"requires_lesson": "siem_monitoring",
		"pages": [
			{
				"title": "Falsos Positivos",
				"description": "No todo el tráfico bloqueado es un ataque...",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			{"id": "dismiss_false_positive", "text": "Descartar 3 falsos positivos"},
			{"id": "resolve_high_alert", "text": "Resolver una alerta de severidad Alta"}
		]
	},
	{
		"id": "mitigation_patching",
		"lesson_name": "06. Mitigación y Parcheo",
		"requires_lesson": "alert_management",
		"pages": [
			{
				"title": "Actualizaciones Críticas",
				"description": "Los atacantes explotarán vulnerabilidades...",
				"image_path": "res://assets/ui/shop/servers/Screenshot From 2026-07-06 22-14-06.png"
			}
		],
		"objectives": [
			{"id": "patch_firmware", "text": "Actualizar el firmware del Servidor Gama Baja"},
			{"id": "deploy_firewall", "text": "Desplegar un Firewall básico en la red"}
		]
	}
]
