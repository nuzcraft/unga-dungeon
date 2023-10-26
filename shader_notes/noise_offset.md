# Noise Offset Shader (Wiggle Shader)

## Setting up a 2D Screenspace Shader in Godot

1. Create a new CanvasLayer in your 2D or 3D scene
2. Create a ColorRect as a child of the CanvasLayer
3. Use the FullRect anchor preset to size the ColorRect to fill the whole screen
4. In the ColorRect, in `CanvasItem`, under `Material`, choose `New Shader Material`
5. In the Material, in `Shader`, choose `New Shader`
6. Here you can choose a name for your shader and we can start customizing!

## Shader Code

```
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D NOISE_TEXTURE: repeat_enable;
uniform float strength: hint_range(0.0, 5, 0.1) = 1.0;
uniform float uv_scaling: hint_range (0.0, 1.0, 0.05) = 1.0;
uniform vec2 movement_direction = vec2(1, 0);
uniform float movement_speed: hint_range (0.0, 0.5, 0.01) = 0.1;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_texture = texture(SCREEN_TEXTURE, uv);
	vec2 movement_factor = movement_direction * movement_speed * TIME;
	float noise_value = texture(NOISE_TEXTURE, uv*uv_scaling + movement_factor).r - 0.5;
	uv += noise_value * SCREEN_PIXEL_SIZE * strength;
	COLOR = texture(SCREEN_TEXTURE, uv);
}
```

## Screenshots

![Wiggle Shader in 2D Scene](../screenshots/011_wiggle_shader_demo_2.gif)

![Wiggle Shader in 3D Scene](../screenshots/012_wiggle_shader_demo_4.gif)

## Breakdown

```
shader_type canvas_item;
```

This is a 2D shader; we indicate that with a canvas_item shader type. I don't have a render mode set, feel free to experiment with render modes here.

```
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D NOISE_TEXTURE: repeat_enable;
```

These are the textures we'll be using. `SCREEN_TEXTURE` is just that, the texture from the screen. There are other options besides filter_linear (filter_nearest, for example), so experiment here if it's not looking quite right. `NOISE_TEXTURE` needs some input from you!

In the `Material`, under `Shader Parameters`, there will be a place for you to add a noise texture (or really any image). Godot can generate noise textures for you, or you can use one you have saved. The `repeat_enable` flag will allow us to move the texture around and it will automatically repeat.

```
uniform float strength: hint_range(0.0, 5, 0.1) = 1.0;
uniform float uv_scaling: hint_range (0.0, 1.0, 0.05) = 1.0;
uniform vec2 movement_direction = vec2(1, 0);
uniform float movement_speed: hint_range (0.0, 0.5, 0.01) = 0.1;
```

These are our parameters for customizing the wiggle effect. `strength` is a multiplier for how much the noise value will offset the pixel. `uv_scaling` allows us to 'zoom in' on our noise texture if we want a less variance across the image; 0.5 essentially reduces the texture to a quarter size. `movement_direction` is for choosing which direction the noise will move across the screen. `movement_speed` will choose how fast the noise moves; 0.0 is no movement.

```
void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_texture = texture(SCREEN_TEXTURE, uv);
	vec2 movement_factor = movement_direction * movement_speed * TIME;
	float noise_value = texture(NOISE_TEXTURE, uv*uv_scaling + movement_factor).r - 0.5;
	uv += noise_value * SCREEN_PIXEL_SIZE * strength;
	COLOR = texture(SCREEN_TEXTURE, uv);
}
```

1. get the coordinates of the pixel and store it in the uv vector
2. get the pixel information from the screen
3. calculate a movement factor based on the given direction and speed multiplied by the variable `TIME`
4. this line has a lot going on:
   - use the `uv_scaling` and `movement_factor` values to get pixel information from the noise texture you input
   - get only the red channel. Noise textures tend to be greyscale, so rgb should be equal.
   - subtract by 0.5. Channel values will be between 0 and 1, subtracting 0.5 will put the values between -0.5 and +0.5 which will help our image stay centered where it normally is.
5. multiply our noise value with the size of a pixel and the `strengh` factor to change the uv coordinates for the pixel
6. draw the pixel back on the screen at new coordinates

## Notes

- I used a blue noise texture that I found online for my examples. It's a more uniform noise pattern than what you tend to get from Godot's noise generator.
- It is possible to convert this shader to a spatial one
  - change COLOR to ALBEDO
  - calculate the SCREEN_PIXEL_SIZE based on the VIEWPORT_SIZE
  - most everything else stays the same

Sprites from Kenney: [kenny.nl](kenney.nl)
