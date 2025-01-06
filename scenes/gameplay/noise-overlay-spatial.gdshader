shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NOISE_TEXTURE;
uniform float strength: hint_range(0.0, 5, 0.1) = 1.0;
uniform float uv_scaling: hint_range (0.0, 1.0, 0.05) = 1.0;

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_texture = texture(SCREEN_TEXTURE, uv);
	float noise_value = texture(NOISE_TEXTURE, uv*uv_scaling).r - 0.5;
	vec2 SCREEN_PIXEL_SIZE = 1.0 / VIEWPORT_SIZE;
	uv += noise_value * SCREEN_PIXEL_SIZE * strength;
	ALBEDO = texture(SCREEN_TEXTURE, uv).rgb;
}
