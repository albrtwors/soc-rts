shader_type spatial; // 🔴 CORREGIDO: Define que es un shader para objetos 3D
render_mode cull_front, unshaded; // cull_front da vuelta las caras; unshaded ignora la luz

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Color del borde
uniform float outline_thickness : hint_range(0.0, 0.1) = 0.02;       // Grosor del borde

void vertex() {
	// Inflamos la malla en la dirección de sus vectores normales
	VERTEX += NORMAL * outline_thickness;
}

void fragment() {
	// Pintamos el borde con un color plano y sólido
	ALBEDO = outline_color.rgb;
}