class_name IsometricCamera extends Camera3D

signal view_rotate(view:int)

@export var object_to_follow_path: NodePath

const positions = [ Vector3(-50, 70, 50), Vector3(-50,70,-50), Vector3(50,70,-50),  Vector3(50,70,50) ]
const rotations = [ Vector3(-45, -45, 0), Vector3(-45,-135,0), Vector3(-45,-225,0), Vector3(-45,45,0) ]

@onready var camera_pivot:Node3D = $".."

# camera pivot
var object_to_follow:Node3D
# isometric view rotation
var _view:int = 0
# camera field of view
var _size:int = 20
# keyboard actions
var zoom_in = false
var zoom_out = false

func _ready():
	projection = Camera3D.PROJECTION_ORTHOGONAL
	_size = GameState.camera.size
	if (_size == -1):
		_size = 10 #30 / get_viewport().content_scale_factor
	_view = GameState.camera.view
	object_to_follow = get_node(object_to_follow_path)
	zoom_view()
	rotate_view()

func _unhandled_input(event):
	if (event is InputEventMouseButton) and (not event.pressed):
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			if (Input.is_action_pressed("modifier")):
				rotate_view(1)
			else:
				zoom_view(2)
		elif (event.button_index == MOUSE_BUTTON_WHEEL_UP):
			if (Input.is_action_pressed("modifier")):
				rotate_view(-1)
			else:
				zoom_view(-2)
	if (event is InputEventJoypadMotion) and Input.is_action_pressed("modifier"):
		if (event.axis == JOY_AXIS_RIGHT_X):
			if (event.axis_value == 1):
				rotate_view(1)
			elif (event.axis_value == -1):
				rotate_view(-1)
		elif (event.axis == JOY_AXIS_RIGHT_Y):
			if (event.axis_value == -1):
				zoom_in = true
				zoom_out = false
			elif (event.axis_value == 1):
				zoom_out = true
				zoom_in = false
			else:
				zoom_in = false
				zoom_out = false

func _unhandled_key_input(event):
	if (event is InputEventKey) and Input.is_action_pressed("modifier"):
		if (event.physical_keycode == KEY_UP):
			if (event.pressed):
				zoom_in = true
			else:
				zoom_in = false
		elif (event.physical_keycode == KEY_DOWN):
			if (event.pressed):
				zoom_out = true
			else:
				zoom_out = false
		elif (event.physical_keycode == KEY_LEFT) and not event.pressed:
			rotate_view(-1)
		elif (event.physical_keycode == KEY_RIGHT) and not event.pressed:
			rotate_view(1)

func _process(_delta):
	camera_pivot.position = object_to_follow.position
	if (zoom_in): 
		zoom_view(-1)
	elif (zoom_out): 
		zoom_view(1)

func zoom_view(delta:int=0):
	_size += delta
	_size = clamp(_size, 5, 30)
	size = _size
	GameState.camera.size = _size

func rotate_view(delta:int=0):
	_view += delta
	_view = clamp(_view, 0, 3)
	position = positions[_view]
	rotation_degrees = rotations[_view]
	GameState.camera.view = _view
	view_rotate.emit(_view)

func move(pos):
	camera_pivot.position = pos
