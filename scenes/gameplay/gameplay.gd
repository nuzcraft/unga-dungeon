extends Node

@onready var iso_camera = $IsoCamera
@onready var side_camera = $SideCamera

@onready var depth_sobel_shader = $Shaders/DepthSobelShader
@onready var normal_sobel_shader = $Shaders/NormalSobelShader
@onready var noise_overlay_shader = $Shaders/NoiseOverlayShader
@onready var noise_overlay_shader_layer = $Shaders/NoiseOverlayShaderLayer
@onready var combined_sobel_shader = $Shaders/CombinedSobelShader
@onready var cross_hatch_shader = $Shaders/ShadowHatchShader
@onready var dither_gradient_shader_layer = $Shaders/DitherGradientShaderLayer
@onready var dither_gradient_shader = $Shaders/DitherGradientShaderLayer/DitherGradientShader
# cross hatch
@onready var scale_h_slider = $UI/VBoxContainer/CrossHatchPanel/MarginContainer/VBoxContainer/ScaleHBoxContainer/ScaleHSlider
@onready var contrast_h_slider = $UI/VBoxContainer/CrossHatchPanel/MarginContainer/VBoxContainer/ContrastHBoxContainer/ContrastHSlider
@onready var brightness_h_slider = $UI/VBoxContainer/CrossHatchPanel/MarginContainer/VBoxContainer/BrightnessHBoxContainer/BrightnessHSlider
# dither
@onready var size_h_slider = $UI/VBoxContainer/DitherPanel/MarginContainer/VBoxContainer/SizeHBoxContainer/SizeHSlider
@onready var dither_contrast_h_slider = $UI/VBoxContainer/DitherPanel/MarginContainer/VBoxContainer/ContrastHBoxContainer/ContrastHSlider
@onready var dither_brightness_h_slider = $UI/VBoxContainer/DitherPanel/MarginContainer/VBoxContainer/BrightnessHBoxContainer/BrightnessHSlider
@onready var bit_depth_h_slider = $UI/VBoxContainer/DitherPanel/MarginContainer/VBoxContainer/BitDepthHBoxContainer2/BitDepthHSlider

@onready var ui = $UI
@onready var cross_hatch_panel = $UI/VBoxContainer/CrossHatchPanel
@onready var dither_panel = $UI/VBoxContainer/DitherPanel

var elapsed = 0

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
	iso_camera.make_current()
	# set sliders
	scale_h_slider.value = cross_hatch_shader.mesh.material.get_shader_parameter("uv_scaling")
	contrast_h_slider.value = cross_hatch_shader.mesh.material.get_shader_parameter("u_contrast")
	brightness_h_slider.value = cross_hatch_shader.mesh.material.get_shader_parameter("u_offset")
	size_h_slider.value = dither_gradient_shader.material.get_shader_parameter("dither_size")
	dither_contrast_h_slider.value = dither_gradient_shader.material.get_shader_parameter("u_contrast")
	dither_brightness_h_slider.value = dither_gradient_shader.material.get_shader_parameter("u_offset")
	bit_depth_h_slider.value = dither_gradient_shader.material.get_shader_parameter("bit_depth")

# `start()` is called after pre_start and after the graphic transition ends.
func start():
	print("gameplay.gd: start() called")

func _process(delta):
	elapsed += delta
	if Input.is_action_just_pressed("hide_ui"):
		if ui.visible:
			ui.hide()
		else:
			ui.show()


func _on_camera_option_button_item_selected(index):
	if index == 0:
		iso_camera.make_current()
	elif index == 1:
		side_camera.make_current()

func _on_restart_scene_pressed():
	get_tree().reload_current_scene()


func _on_depth_sobel_shader_selector_toggled(button_pressed):
	if button_pressed:
		depth_sobel_shader.show()
	else:
		depth_sobel_shader.hide()
		
func _on_normal_sobel_shader_selector_toggled(button_pressed):
	if button_pressed:
		normal_sobel_shader.show()
	else:
		normal_sobel_shader.hide()

func _on_no_shader_selector_toggled(button_pressed):
	if button_pressed:
		depth_sobel_shader.hide()
		normal_sobel_shader.hide()

func _on_noise_overlay_canvas_shader_toggled(button_pressed):
	if button_pressed:
		noise_overlay_shader_layer.show()
	else:
		noise_overlay_shader_layer.hide()

func _on_noise_overlay_spatial_shader_toggled(button_pressed):
	if button_pressed:
		noise_overlay_shader.show()
	else:
		noise_overlay_shader.hide()

func _on_combined_sobel_shader_toggled(button_pressed):
	if button_pressed:
		combined_sobel_shader.show()
	else:
		combined_sobel_shader.hide()

func _on_cross_hatch_shader_toggled(button_pressed):
	if button_pressed:
		cross_hatch_shader.show()
		cross_hatch_panel.show()
	else:
		cross_hatch_shader.hide()
		cross_hatch_panel.hide()

func _on_dither_gradient_shader_toggled(button_pressed):
	if button_pressed:
		dither_gradient_shader_layer.show()
		dither_panel.show()
	else:
		dither_gradient_shader_layer.hide()
		dither_panel.hide()

func _on_scale_h_slider_drag_ended(value_changed):
	if value_changed:
		cross_hatch_shader.mesh.material.set_shader_parameter("uv_scaling", scale_h_slider.value)
		scale_h_slider.value = cross_hatch_shader.mesh.material.get_shader_parameter("uv_scaling")

func _on_contrast_h_slider_drag_ended(value_changed):
	if value_changed:
		cross_hatch_shader.mesh.material.set_shader_parameter("u_contrast", contrast_h_slider.value)
		contrast_h_slider.value = cross_hatch_shader.mesh.material.get_shader_parameter("u_contrast")

func _on_brightness_h_slider_drag_ended(value_changed):
	if value_changed:
		cross_hatch_shader.mesh.material.set_shader_parameter("u_offset", brightness_h_slider.value)
		brightness_h_slider.value = cross_hatch_shader.mesh.material.get_shader_parameter("u_offset")

func _on_scale_h_slider_value_changed(value):
	cross_hatch_shader.mesh.material.set_shader_parameter("uv_scaling", value)

func _on_contrast_h_slider_value_changed(value):
	cross_hatch_shader.mesh.material.set_shader_parameter("u_contrast", value)

func _on_brightness_h_slider_value_changed(value):
	cross_hatch_shader.mesh.material.set_shader_parameter("u_offset", value)

func _on_size_h_slider_value_changed(value):
	dither_gradient_shader.material.set_shader_parameter("dither_size", value)

func _on_size_h_slider_drag_ended(value_changed):
	if value_changed:
		dither_gradient_shader.material.set_shader_parameter("dither_size", size_h_slider.value)
		size_h_slider.value = dither_gradient_shader.material.get_shader_parameter("dither_size")

func _on_dither_contrast_h_slider_value_changed(value):
	dither_gradient_shader.material.set_shader_parameter("u_contrast", value)

func _on_dither_contrast_h_slider_drag_ended(value_changed):
	if value_changed:
		dither_gradient_shader.material.set_shader_parameter("u_contrast", dither_contrast_h_slider.value)
		dither_contrast_h_slider.value = dither_gradient_shader.material.get_shader_parameter("u_contrast")

func _on_dither_brightness_h_slider_value_changed(value):
	dither_gradient_shader.material.set_shader_parameter("u_offset", value)

func _on_dither_brightness_h_slider_drag_ended(value_changed):
	if value_changed:
		dither_gradient_shader.material.set_shader_parameter("u_offset", dither_brightness_h_slider.value)
		dither_brightness_h_slider.value = dither_gradient_shader.material.get_shader_parameter("u_offset")

func _on_bit_depth_h_slider_value_changed(value):
	dither_gradient_shader.material.set_shader_parameter("bit_depth", value)

func _on_bit_depth_h_slider_drag_ended(value_changed):
	if value_changed:
		dither_gradient_shader.material.set_shader_parameter("bit_depth", bit_depth_h_slider.value)
		bit_depth_h_slider.value = dither_gradient_shader.material.get_shader_parameter("bit_depth")
