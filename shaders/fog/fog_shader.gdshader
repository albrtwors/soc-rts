shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never;

uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

// Parámetros Estilo de las Nubes
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);  
uniform vec3 ground_color : source_color = vec3(0.01, 0.05, 0.1); 

// Forma y Animación
uniform float cloud_scale : hint_range(0.01, 2.0) = 0.1;    // Escala corregida para coordenadas UV nativas
uniform float cloud_density : hint_range(0.0, 1.0) = 0.5;   
uniform float animation_speed : hint_range(0.0, 5.0) = 0.5;  
uniform float toon_sharpness : hint_range(0.0, 1.0) = 0.05;  

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
    // Mantiene el plano persiguiendo a la cámara en el eje X y Z
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    VERTEX += (CAMERA_POSITION_WORLD - world_pos) * vec3(1.0, 0.0, 1.0);
}

void fragment() {
    // 🎯 LA CORRECCIÓN: Usamos UV nativas del plano en lugar de SCREEN_UV
    // Esto asegura que el ruido matemático se dibuje correctamente sobre la superficie
    vec2 custom_uv = UV * cloud_scale;
    
    // Desplazamiento animado continuo
    custom_uv.x += TIME * animation_speed * 0.05;
    custom_uv.y += TIME * animation_speed * 0.02;

    // Capas de ruido procedural
    float n1 = noise(custom_uv * 100.0);
    float n2 = noise(custom_uv * 200.0 + vec2(TIME * 0.02));
    float combined_noise = (n1 + n2) * 0.5;

    // Máscara Toon (Cel-shaded)
    float cloud_mask = smoothstep(1.0 - cloud_density - toon_sharpness, 1.0 - cloud_density + toon_sharpness, combined_noise);

    // Color final interpolado
    vec3 final_color = mix(ground_color, cloud_color, cloud_mask);

    float depth = texture(depth_texture, SCREEN_UV).r;

    if (depth >= 1.0) {
        final_color = ground_color;
    }

    ALBEDO = final_color;
    ALPHA = 1.0;
}