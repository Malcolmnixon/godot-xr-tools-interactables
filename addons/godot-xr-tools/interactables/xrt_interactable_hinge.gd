class_name XRTInteractableHinge
extends XRTInteractableHandleDriven


##
## Interactable Hinge script
##
## @desc:
##     The interactable hinge is a hinge transform node controlled by the
##     player through interactable handles.
##
##     The hinge rotates itelf around its local X axis, and so should be
##     placed as a child of a spatial node to translate and rotate as 
##     appropriate.
##
##     The interactable hinge is not a rigid body, and as such will not react
##     to any collisions.
##  

## Signal for hinge moved
signal hinge_moved(angle)


## Hinge minimum limit
export var hinge_limit_min := -45.0 setget _set_hinge_limit_min

## Hinge maximum limit
export var hinge_limit_max := 45.0 setget _set_hinge_limit_max

## Hinge step size (zero for no steps)
export var hinge_steps := 0.0 setget _set_hinge_steps

## Hinge position
export var hinge_position := 0.0 setget _set_hinge_position


# Hinge values in radians
onready var _hinge_limit_min_rad := deg2rad(hinge_limit_min)
onready var _hinge_limit_max_rad := deg2rad(hinge_limit_max)
onready var _hinge_steps_rad := deg2rad(hinge_steps)
onready var _hinge_position_rad := deg2rad(hinge_position)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the initial position to match the initial hinge position value
	transform = Transform(Basis(Vector3.RIGHT, _hinge_position_rad), Vector3.ZERO)


# Called every frame when one or more handles are held by the player
func _process(var _delta: float) -> void:
	# Get the total handle angular offsets
	var offset_sum := 0.0
	for item in grabbed_handles:
		var handle := item as XRTInteractableHandle
		var to_handle: Vector3 = global_transform.xform_inv(handle.global_transform.origin) 
		var to_handle_origin: Vector3 = global_transform.xform_inv(handle.handle_origin.global_transform.origin)
		to_handle.x = 0.0
		to_handle_origin.x = 0.0
		offset_sum += to_handle_origin.signed_angle_to(to_handle, Vector3.RIGHT)

	# Average the angular offsets
	var offset := offset_sum / grabbed_handles.size()

	# Move the hinge by the requested offset
	move_hinge(_hinge_position_rad + offset)


# Move the hinge to the specified position
func move_hinge(var position: float) -> void:
	# Apply slider step-quantization
	if _hinge_steps_rad:
		position = round(position / _hinge_steps_rad) * _hinge_steps_rad

	# Apply slider limits
	position = clamp(position, _hinge_limit_min_rad, _hinge_limit_max_rad)

	# Skip if the position has not changed
	if position == _hinge_position_rad:
		return

	# Update the current positon
	_hinge_position_rad = position
	hinge_position = rad2deg(position)

	# Update the transform
	transform.basis = Basis(Vector3.RIGHT, position)

	# Emit the moved signal
	emit_signal("hinge_moved", hinge_position)


# Called when hinge_limit_min is set externally
func _set_hinge_limit_min(var value: float) -> void:
	hinge_limit_min = value
	_hinge_limit_min_rad = deg2rad(value)


# Called when hinge_limit_max is set externally
func _set_hinge_limit_max(var value: float) -> void:
	hinge_limit_max = value
	_hinge_limit_max_rad = deg2rad(value)


# Called when hinge_steps is set externally
func _set_hinge_steps(var value: float) -> void:
	hinge_steps = value
	_hinge_steps_rad = deg2rad(value)


# Called when hinge_position is set externally
func _set_hinge_position(var value: float) -> void:
	hinge_position = value
	_hinge_position_rad = deg2rad(value)
	move_hinge(_hinge_position_rad)
