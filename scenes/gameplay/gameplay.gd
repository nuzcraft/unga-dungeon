extends Node

@onready var iso_camera = $IsoCamera
@onready var side_camera = $SideCamera

@onready var depth_sobel_shader = $Shaders/DepthSobelShader
@onready var normal_sobel_shader = $Shaders/NormalSobelShader
@onready var noise_overlay_shader = $Shaders/NoiseOverlayShader
@onready var noise_overlay_shader_layer = $Shaders/NoiseOverlayShaderLayer

@onready var ui = $UI

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
