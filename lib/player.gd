class_name Player extends CharacterBody3D

signal start_moving()
signal moving()
signal stop_moving()

const ANIM_STANDING = "standing"
const ANIM_WALKING = "walking"
const ANIM_RUNNING = "running"

@export var camera_pivot:Node3D

@onready var anim:AnimationPlayer = $AnimationPlayer 
@onready var character:Node3D = $Character

const walking_speed:float = 7.0
const running_speed:float = 14.0

var camera:IsometricCamera

# for move_and_slide()
var speed:float = 0.0
var fall_acceleration:float = 200.0
var target_velocity:Vector3 = Vector3.ZERO

# isometric current view rotation
var current_view:int = 0
# player movement signaled
var signaled:bool = false

const directions = {
	"forward" : 	[  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 } ],
	"left" : 		[  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 } ],
	"backward" : 	[  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 },  { 'x':  1, 'z':  1 } ],
	"right" : 		[  { 'x':  1, 'z':  1 },  { 'x': -1, 'z':  1 },  { 'x': -1, 'z': -1 },  { 'x':  1, 'z': -1 } ]
}

func _ready():
	camera = camera_pivot.get_node("Camera")
	camera.connect("view_rotate", _on_view_rotate)

func _physics_process(delta):
	var on_floor = is_on_floor_only() 
	var direction = Vector3.ZERO
	if Input.is_action_pressed("player_right"):
		direction.x += directions["right"][current_view].x
		direction.z += directions["right"][current_view].z
	if Input.is_action_pressed("player_left"):
		direction.x += directions["left"][current_view].x
		direction.z += directions["left"][current_view].z
	if Input.is_action_pressed("player_backward"):
		direction.x += directions["backward"][current_view].x
		direction.z += directions["backward"][current_view].z
	if Input.is_action_pressed("player_forward"):
		direction.x += directions["forward"][current_view].x
		direction.z += directions["forward"][current_view].z
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		look_at(position + direction, Vector3.UP)
		_run_or_walk(delta)
	else:
		target_velocity.y = 0
		signaled = false
		stop_moving.emit()
		anim.play(ANIM_STANDING, 0.2)
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	if not on_floor:
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	velocity = target_velocity
	move_and_slide()
	if direction != Vector3.ZERO:
		_update_camera()

func _run_or_walk(delta):
	if Input.is_action_pressed("modifier"):
		speed = running_speed
		anim.play(ANIM_RUNNING, 0.1)
	else:
		speed = walking_speed
		anim.play(ANIM_WALKING, 0.1)
	moving.emit()

func move(pos:Vector3, rot:Vector3):
	position = pos
	rotation = rot
	_update_camera()

func _update_camera():
	camera_pivot.position = position
	camera_pivot.position.y += 1.5
	if (!signaled) :
		start_moving.emit()
		signaled = true

func _on_view_rotate(view:int):
	current_view = view
