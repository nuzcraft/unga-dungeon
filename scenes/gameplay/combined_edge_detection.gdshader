shader_type spatial;
render_mode blend_mix;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear;

uniform float depth_edge_threshold_lower: hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float depth_edge_threshold_upper: hint_range(0.0, 1.0, 0.05) = 0.3;
uniform float normal_edge_threshold: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform vec3 line_color: source_color = vec3(0.41, 0.37, 0.42);
uniform vec3 background_color: source_color = vec3(0.9, 1.0, 0.93);

const mat3 sobel_y = mat3(
	vec3(1.0, 0.0, -1.0),
	vec3(2.0, 0.0, -2.0),
	vec3(1.0, 0.0, -1.0)
);

const mat3 sobel_x = mat3(
	vec3(1.0, 2.0, 1.0),
	vec3(0.0, 0.0, 0.0),
	vec3(-1.0, -2.0, -1.0)
);

float linearize_depth(vec2 uv_coord, mat4 proj_matrix){
	float depth = texture(DEPTH_TEXTURE, uv_coord).x;
	vec3 ndc = vec3(uv_coord, depth) * 2.0 - 0.0;
	vec4 view = proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	return linear_depth;
}

vec3 normalize_normal(vec3 normal){
	return normalize(normal * 2.0 - 1.0);
}

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	vec2 screen_pixel_size = 0.5 / VIEWPORT_SIZE;

	// depth section
	float depth = linearize_depth(uv, INV_PROJECTION_MATRIX);

	float n = linearize_depth(uv + vec2(0.0, -screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float s = linearize_depth(uv + vec2(0.0, screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float e = linearize_depth(uv + vec2(screen_pixel_size.x, 0.0), INV_PROJECTION_MATRIX);
	float w = linearize_depth(uv + vec2(-screen_pixel_size.x, 0.0), INV_PROJECTION_MATRIX);
	float nw = linearize_depth(uv + vec2(-screen_pixel_size.x, -screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float ne = linearize_depth(uv + vec2(screen_pixel_size.x, -screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float sw = linearize_depth(uv + vec2(-screen_pixel_size.x, screen_pixel_size.y), INV_PROJECTION_MATRIX);
	float se = linearize_depth(uv + vec2(screen_pixel_size.x, screen_pixel_size.y), INV_PROJECTION_MATRIX);

	mat3 depth_surrounding_pixels = mat3(
		vec3(nw, n, ne),
		vec3(w, depth, e),
		vec3(sw, s, se)
	);

	float depth_edge_x = dot(sobel_x[0], depth_surrounding_pixels[0]) + dot(sobel_x[1], depth_surrounding_pixels[1]) + dot(sobel_x[2], depth_surrounding_pixels[2]);
	float depth_edge_y = dot(sobel_y[0], depth_surrounding_pixels[0]) + dot(sobel_y[1], depth_surrounding_pixels[1]) + dot(sobel_y[2], depth_surrounding_pixels[2]);

	float depth_edge = sqrt(pow(depth_edge_x, 2.0)+pow(depth_edge_y, 2.0));

	// normal section
	vec3 normal = normalize_normal(texture(NORMAL_TEXTURE, uv).rgb);

	vec3 n_n = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(0.0, -screen_pixel_size.y)).rgb);
	vec3 n_s = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(0.0, screen_pixel_size.y)).rgb);
	vec3 n_e = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(screen_pixel_size.x, 0.0)).rgb);
	vec3 n_w = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-screen_pixel_size.x, 0.0)).rgb);
	vec3 n_nw = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-screen_pixel_size.x, -screen_pixel_size.y)).rgb);
	vec3 n_ne = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(screen_pixel_size.x, -screen_pixel_size.y)).rgb);
	vec3 n_sw = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-screen_pixel_size.x, screen_pixel_size.y)).rgb);
	vec3 n_se = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(screen_pixel_size.x, screen_pixel_size.y)).rgb);

	mat3 normal_surrounding_pixels = mat3(
		vec3(length(n_nw-normal), length(n_n-normal), length(n_ne-normal)),
		vec3(length(n_w-normal), length(normal-normal), length(n_e-normal)),
		vec3(length(n_sw-normal), length(n_s-normal), length(n_se-normal))
	);

	float normal_edge_x = dot(sobel_x[0], normal_surrounding_pixels[0]) + dot(sobel_x[1], normal_surrounding_pixels[1]) + dot(sobel_x[2], normal_surrounding_pixels[2]);
	float normal_edge_y = dot(sobel_y[0], normal_surrounding_pixels[0]) + dot(sobel_y[1], normal_surrounding_pixels[1]) + dot(sobel_y[2], normal_surrounding_pixels[2]);

	float normal_edge = sqrt(pow(normal_edge_x, 2.0)+pow(normal_edge_y, 2.0));

	if (normal_edge > normal_edge_threshold) {
		ALBEDO = line_color;
	} else if (depth_edge > depth_edge_threshold_lower && normal_edge > 0.0) {
		ALBEDO = line_color;
	} else if (depth_edge > depth_edge_threshold_upper) {
		ALBEDO = line_color;
	} else {
		ALBEDO = background_color;
	}
}
