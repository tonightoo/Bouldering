shader_type canvas_item;

uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.2;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float dist = distance(UV, vec2(0.5));    
    float v = smoothstep(vignette_radius, vignette_radius + vignette_softness, dist);    
    COLOR = vec4(vignette_color.rgb, v * vignette_opacity);
}