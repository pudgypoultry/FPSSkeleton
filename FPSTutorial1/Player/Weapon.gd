extends Spatial

class_name Weapon

export var fire_rate = 0.5
export var clip_size = 5
export var reload_rate = 1
export var default_position : Vector3
export var ads_position : Vector3
export var ads_acceleration : float = 0.3
export var default_fov : float = 70
export var ads_fov : float = 55
export (PackedScene) var Bullet


onready var ammo_label = $"/root/World/UI/AmmoLabel"
export var raycast_path : NodePath
export var camera_path : NodePath
export var muzzle_location_path : NodePath

var raycast : RayCast
var camera : Camera
var muzzle_location : Spatial

var current_ammo = 0
var can_fire = true
var reloading = false

func _ready():
	current_ammo = clip_size
	raycast = get_node(raycast_path)
	camera = get_node(camera_path)
	muzzle_location = get_node(muzzle_location_path)

func _process(delta):
	if reloading:
		ammo_label.set_text("Reloading...")
	else:
		ammo_label.set_text("%d / %d" % [current_ammo, clip_size])
	
	if Input.is_action_just_pressed("primary_fire") and can_fire:
		if current_ammo > 0 and not reloading:
			fire()
		elif not reloading:
			reload()
	
	if Input.is_action_just_pressed("reload") and not reloading:
		reload()
	
	if Input.is_action_pressed("ads"):
		transform.origin = transform.origin.linear_interpolate(ads_position, ads_acceleration)
		camera.fov = lerp(camera.fov, ads_fov, ads_acceleration)
	else:
		transform.origin = transform.origin.linear_interpolate(default_position, ads_acceleration)
		camera.fov = lerp(camera.fov, default_fov, ads_acceleration)

func check_collision():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("Enemies"):
			collider.queue_free()
			print("Killed " + collider.name)

func fire():
	print("Fired Weapon")
	can_fire = false
	current_ammo -= 1
	
	# Hitscan Test
	"""
	check_collision()
	yield(get_tree().create_timer(fire_rate), "timeout")
	"""
	
	# Projectile Test
	var b = Bullet.instance()
	owner.add_child(b)
	b.transform = muzzle_location.global_transform
	print(b.transform)
	b.velocity = -b.transform.basis.z * b.muzzle_velocity
	
	can_fire = true

func reload():
	print("Reloading!!!")
	reloading = true
	yield(get_tree().create_timer(reload_rate), "timeout")
	reloading = false
	current_ammo = clip_size
	print("Reload Complete.")
