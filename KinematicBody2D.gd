extends KinematicBody2D

# Player Values #
const speed = 200 #200
const jump = -350
const gravity = 20

var jumps = 0
var extrajumps = 2
const UP = Vector2(0, -1)
var motion = Vector2()

# Player Camera #
onready var PlayerCamera = $Camera2D
const CameraMaxZoom = 0.6
const CameraMinZoom = 0.3

func zoom():
	if Input.is_action_just_released("wheel_down") and PlayerCamera.zoom.y < CameraMaxZoom and PlayerCamera.zoom.x < CameraMaxZoom:
		PlayerCamera.zoom.x += 0.1
		PlayerCamera.zoom.y += 0.1
	if Input.is_action_just_released('wheel_up') and PlayerCamera.zoom.y > CameraMinZoom and PlayerCamera.zoom.x > CameraMinZoom:
		PlayerCamera.zoom.x -= 0.1
		PlayerCamera.zoom.y -= 0.1


func _physics_process(_delta):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	zoom()
			
	motion.y += gravity
	
	if Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
		motion.x = speed
		
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		motion.x = -speed
	else:
		motion.x = 0
		
	if Input.is_action_just_pressed("ui_up"):
		if jumps < extrajumps:
			motion.y = jump
			jumps += 1
		
	if is_on_floor():
		jumps = 0
	
	motion = move_and_slide(motion, UP)
