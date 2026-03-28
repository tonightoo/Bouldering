shader_type canvas_item;
uniform float blur_amount : hint_range(0, 5) = 2.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	float avg = (color.r + color.g + color.b) / 3.0;
	COLOR = vec4(mix(color.rgb, vec3(avg), 0.3), 1.0);
}