shader_type spatial;
render_mode unshaded;

uniform float uv_scaling: hint_range (0.0, 50.0, 1.0) = 10.0;
uniform float u_contrast: hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float u_offset: hint_range(0.0, 1.0, 0.01) = 0.0;

uniform vec3 background_color: source_color = vec3(1.0);

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D HATCH_TEXTURE_R: repeat_enable, filter_linear;
uniform sampler2D HATCH_TEXTURE_G: repeat_enable, filter_linear;
uniform sampler2D HATCH_TEXTURE_B: repeat_enable, filter_linear;

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 hatch_texture_r = 1.0 - texture(HATCH_TEXTURE_R, uv * uv_scaling).rgb;
	vec3 hatch_texture_g = 1.0 - texture(HATCH_TEXTURE_G, uv * uv_scaling).rgb;
	vec3 hatch_texture_b = 1.0 - texture(HATCH_TEXTURE_B, uv * uv_scaling).rgb;

	float luminance = 0.299*screen_color.r + 0.587*screen_color.g + 0.144*screen_color.b;

	float contrast = u_contrast;
	luminance = (luminance - 0.5 + u_offset) * contrast + 0.5;
	luminance = clamp(luminance, 0.0, 1.0);

	screen_color.rgb = background_color;
	if (luminance < 0.75) {
		screen_color = screen_color - hatch_texture_r;
	}
	if (luminance < 0.5) {
		screen_color = screen_color.rgb - hatch_texture_g;
	}
	if (luminance < 0.25) {
		screen_color = screen_color - hatch_texture_b;
	}

	ALBEDO = screen_color.rgb;
}
