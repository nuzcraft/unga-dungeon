shader_type canvas_item;

uniform sampler2D dither_tex: filter_nearest, repeat_enable;
uniform sampler2D color_tex: filter_nearest, repeat_disable;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;

uniform float dither_size: hint_range(0.5, 10.0, 0.5) = 1.0;
uniform float u_contrast: hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float u_offset: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform int bit_depth: hint_range(0, 20, 1) = 5;

void fragment() {
	// this part by itself will pixelate the output, very cool
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0)) / float(dither_size);
	vec2 screen_sample_uv = floor(UV * screen_size) / screen_size;
	vec3 screen_color = texture(SCREEN_TEXTURE, screen_sample_uv).rgb;
	
	// calculate luminosity of the pixel
	float lum = (screen_color.r * 0.299) + (screen_color.g * 0.587) + (screen_color.b * 0.114);
	
	// adjust with contrast and offset parameters
	float contrast = u_contrast;
	lum = (lum - 0.5 + u_offset) * contrast + 0.5;
	lum = clamp(lum, 0.0, 1.0);
	
	// reduce bit depth to give luminosity more banded visual
	float bits = float(bit_depth);
	lum = floor(lum * bits) / bits;
	
	// I don't understand this part yet
	ivec2 col_size = textureSize(color_tex, 0);
	col_size /= col_size.y;
	
	float col_x = float(col_size.x) - 1.0;
	float col_texel_size = 1.0 / col_x;
	
	lum = max(lum - 0.00001, 0.0);
	float lum_lower = floor(lum * col_x) * col_texel_size;
	float lum_upper = (floor(lum * col_x) + 1.0) * col_texel_size;
	float lum_scaled = lum * col_x - floor(lum * col_x);
		
	// map the dither onto the screen
	ivec2 noise_size = textureSize(dither_tex, 0);
	vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
	vec2 noise_uv = UV * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
	float threshold = texture(dither_tex, noise_uv).r;
	
	float ramp_val = lum_scaled < threshold ? 0.0f: 1.0f;
	float col_sample = mix(lum_lower, lum_upper, ramp_val);
	vec3 final_col = texture(color_tex, vec2(col_sample, 0.5)).rgb;
		
	COLOR.rgb = final_col;
}
