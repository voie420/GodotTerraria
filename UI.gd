extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var Viewport = get_global_transform_with_canvas()
onready var ControlTextureRect = $Control/TextureRect

func _process(delta):
	ControlTextureRect.rect_position.x + 200
	ControlTextureRect.set_position(Vector2(Viewport + 20, Viewport + 20))
