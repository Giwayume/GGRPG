extends Sprite

#---------#
# Exports #
#---------#

export var alpha_clip = 0.5 # Decrease to 0.01 to dither transparent objects
export var always_update: bool = false setget _set_always_update # Use if the sprite changes position from its initial placement during gameplay
export var height = 0.0 setget _set_height # The height of the floor this sprite represents
export var use_dithering = true # Dither alpha values, disabled when use_transparency is true
export var use_dither_blending = true # Offset alpha dithering pattern every frame to create a smoothing effect
export var use_transparency: bool = false # Allow partial transparency, but greatly reduces depth drawing accuracy

#------------#
# Properties #
#------------#

var depth_test_mesh = null
var frame_width = 0
var frame_height = 0
var is_ready = false
var last_frame = -1
var was_flip_h = false

#-------------------#
# Getters / Setters #
#-------------------#

func _set_always_update(new_always_update):
	always_update = new_always_update
	set_physics_process(always_update)
	set_process(always_update)

func _set_height(new_height):
	height = new_height
	if is_ready and not always_update:
		_generate_meshes()

#----------------#
# Node Lifecycle #
#----------------#

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_clear_depth_test_meshes()

func _ready():
	is_ready = true
	_calculate_frame_size()
	_generate_meshes()
	set_physics_process(always_update)
	set_process(always_update)

func _enter_tree():
	_calculate_frame_size()
	if is_ready:
		_generate_meshes()

func _exit_tree():
	_clear_depth_test_meshes()

func _physics_process(_delta):
	if depth_test_mesh:
		var mesh = depth_test_mesh.get_ref()
		if mesh:
			if frame != last_frame:
				last_frame = frame
				mesh.material_override.set_shader_param("sprite_animation_frame", frame)
			if flip_h != was_flip_h:
				was_flip_h = flip_h
				mesh.material_override.set_shader_param("sprite_flip_h", -1 if flip_h else 1)
			mesh.global_translation = Vector3(
				global_position.x + offset.x,
				global_position.y + offset.y,
				-global_position.y - height
			)

#----------------#
# Public Methods #
#----------------#

func update_mesh():
	if not depth_test_mesh:
		return
	var mesh = depth_test_mesh.get_ref()
	if mesh:
		mesh.material_override.set_shader_param("alpha_clip", alpha_clip)
		mesh.material_override.set_shader_param("dither_limit_min", 0.0 if use_dithering else 1.0)
		mesh.material_override.set_shader_param("dither_time_coord_multiplier", 1.0 if use_dither_blending else 0.0)
		mesh.material_override.set_shader_param("sprite_flip_h", -1 if flip_h else 1)
		mesh.material_override.set_shader_param("sprite_modulate", modulate * self_modulate)

#-----------------#
# Private Methods #
#-----------------#

func _calculate_frame_size():
	if texture:
		frame_width = round(texture.get_size().x / hframes)
		frame_height = round(texture.get_size().y / vframes)

func _clear_depth_test_meshes():
	if depth_test_mesh != null:
		Global.depth_buffer.remove_depth_test_mesh(depth_test_mesh)
		depth_test_mesh = null

func _generate_meshes():
	_clear_depth_test_meshes()
	
	if not visible:
		return
		
	var texture_size = texture.get_size() / Vector2(hframes, vframes)
	var top_left = (-Vector2(texture_size.x / 2, texture_size.y / 2) if centered else Vector2.ZERO)
	var top_right = top_left + Vector2(texture_size.x, 0.0)
	var bottom_left = top_left + Vector2(0.0, texture_size.y)
	var bottom_right = top_left + Vector2(texture_size.x, texture_size.y)
	
	var sprite_transform = Transform2D().scaled(scale).rotated(rotation)

	var vertices = PoolVector2Array()
	vertices.push_back(sprite_transform.xform(top_left))
	vertices.push_back(sprite_transform.xform(top_right))
	vertices.push_back(sprite_transform.xform(bottom_left))
	vertices.push_back(sprite_transform.xform(bottom_right))
	var uvs = PoolVector2Array()
	uvs.push_back(Vector2(0, 0))
	uvs.push_back(Vector2(1, 0))
	uvs.push_back(Vector2(0, 1))
	uvs.push_back(Vector2(1, 1))
	var depth_test = PoolRealArray()
	var top = INF
	var bottom = -INF
	for vertex in vertices:
		if vertex.y < top:
			top = vertex.y
		if vertex.y > bottom:
			bottom = vertex.y
	for vertex in vertices:
		depth_test.push_back(1.0 - ((vertex.y - top) / (bottom - top)))
	depth_test_mesh = Global.depth_buffer.add_depth_test_mesh(
		vertices,
		uvs,
		depth_test,
		Vector2(-bottom, -top),
		texture,
		Vector2(global_position.x, global_position.y),
		use_transparency
	)
	
	var mesh = depth_test_mesh.get_ref()
	if mesh:
		if hframes != 1 or vframes != 1:
			mesh.material_override.set_shader_param("sprite_animation_hframes", hframes)
			mesh.material_override.set_shader_param("sprite_animation_vframes", vframes)
			mesh.material_override.set_shader_param("sprite_animation_frame", frame)
		mesh.material_override.set_shader_param("alpha_clip", alpha_clip)
		mesh.material_override.set_shader_param("dither_limit_min", 0.0 if use_dithering else 1.0)
		mesh.material_override.set_shader_param("dither_time_coord_multiplier", 1.0 if use_dither_blending else 0.0)
		mesh.material_override.set_shader_param("sprite_flip_h", -1 if flip_h else 1)
		mesh.material_override.set_shader_param("sprite_modulate", modulate * self_modulate)
		was_flip_h = flip_h
		mesh.global_translation = Vector3(
			global_position.x,
			global_position.y,
			-global_position.y - height
		)
