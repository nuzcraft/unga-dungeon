shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D HATCH_TEXTURE_R: repeat_enable, filter_nearest;
uniform sampler2D HATCH_TEXTURE_G: repeat_enable, filter_nearest;
uniform sampler2D HATCH_TEXTURE_B: repeat_enable, filter_nearest;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	vec3 hatch_texture_r = texture(HATCH_TEXTURE_R, uv * 10.0).rgb;
	vec3 hatch_texture_g = texture(HATCH_TEXTURE_G, uv * 10.0).rgb;
	vec3 hatch_texture_b = texture(HATCH_TEXTURE_B, uv * 10.0).rgb;
	
	float luminance = 0.299*screen_color.r + 0.587*screen_color.g + 0.144*screen_color.b;
	
	if (luminance < 0.15) {
		screen_color = vec4(screen_color.rgb - hatch_texture_r, screen_color.a);
	}
	if (luminance < 0.1) {
		screen_color = vec4(screen_color.rgb - hatch_texture_g, screen_color.a);
	}
	if (luminance < 0.05) {
		screen_color = vec4(screen_color.rgb - hatch_texture_b, screen_color.a);
	}
	
	ALBEDO = screen_color.rgb;
}
