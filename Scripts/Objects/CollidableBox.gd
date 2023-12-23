# This node generates a basic collision box that the player can jump on to 
# The grid_size is how many units in the tilemap the box takes up.
#   - a value of 1,1 means the space of a full 63 x 28 tile is taken.
#   - increasing x expands the box diagonally up left (-x axis on tile map).
#   - increasing y expands the box diagonally up right (-y axis on tile map).
# The height is specified in pixels.

tool
extends Node2D

#---------#
# Imports #
#---------#

var collision_body_script = preload("res://Scripts/Objects/CollidableBoxCollisionBody.gd")
var floor_layer_script = preload("res://Scripts/FloorLayer.gd")
var floor_setter_script = preload("res://Scripts/FloorSetter.gd")

#---------#
# Exports #
#---------#

export var grid_size = Vector2(1, 1) setget set_grid_size
export(Texture) var texture setget set_texture
export var texture_offset = Vector2.ZERO setget set_texture_offset
export var height = 0.0 setget set_height
export var floor_height = 0.0 setget set_floor_height
export var preview_collision_box = true setget set_preview_collision_box

#------------#
# Properties #
#------------#

const COLLISION_PREVIEW_DRAW_OFFSET = 1000.0
const HALF_TILE_WIDTH = 63.0 / 2.0
const HALF_TILE_HEIGHT = 28.0 / 2.0

var collider_edges = null
var collision_body = null # blocks player/npc from moving here
var collision_body_shape = null # belongs to collision_body
var collision_preview_mesh = null # editor preview mesh of collision box
var floor_notify_area = null # notifies player/npc of floor height when collision_body non-blocking
var floor_notify_area_shape = null # belongs to floor_notify_area
var is_queued_generate_collider = false
var is_queued_generate_collision_box_preview = false
var is_queued_generate_region_sprites = false
var is_ready = false # _ready() already called
var region_sprites_y_sort = null # y-sort container for sprites
var region_sprites = [] # texture is split into multiple sprites with texture regions for y-sorting

#-------------------#
# Getters / Setters #
#-------------------#

func set_texture(new_texture):
	texture = new_texture
	if is_ready:
		_queue_generate_region_sprites()

func set_texture_offset(new_texture_offset):
	texture_offset = new_texture_offset
	if is_ready:
		_queue_generate_region_sprites()

func set_grid_size(new_grid_size):
	grid_size = new_grid_size
	if is_ready:
		_generate_collider_edges()
		_queue_generate_collider()
		_queue_generate_region_sprites()
		_queue_generate_collision_box_preview()

func set_height(new_height):
	height = new_height
	if is_ready:
		_queue_generate_collider()
		_queue_generate_collision_box_preview()

func set_floor_height(new_floor_height):
	floor_height = new_floor_height
	if is_ready:
		_queue_generate_region_sprites()
		_queue_generate_collider()
		_queue_generate_collision_box_preview()

func set_preview_collision_box(new_preview_collision_box):
	preview_collision_box = new_preview_collision_box
	if is_ready:
		_queue_generate_collision_box_preview()

#----------------#
# Node Lifecycle #
#----------------#

func _ready():
	is_ready = true
	
	_initialize_nodes()

func _enter_tree():
	if is_ready:
		_initialize_nodes()

#---------#
# Methods #
#---------#

func _initialize_nodes():
	for child in get_children():
		if child != null and weakref(child).get_ref():
			child.queue_free()
	
	collider_edges = null
	collision_body = null
	collision_body_shape = null
	collision_preview_mesh = null
	floor_notify_area = null
	floor_notify_area_shape = null
	region_sprites_y_sort = null
	region_sprites = []

	_generate_collider_edges()
	_queue_generate_collider()
	_queue_generate_region_sprites()
	_queue_generate_collision_box_preview()

func _queue_generate_collider():
	if not is_queued_generate_collider:
		is_queued_generate_collider = true
		call_deferred("_generate_collider")

func _generate_collider():
	is_queued_generate_collider = false
	if Engine.editor_hint:
		return
	
	if collision_body == null or not weakref(collision_body).get_ref():
		collision_body = StaticBody2D.new()
		collision_body.owner = self
		collision_body.name = "CollisionBody"
		collision_body.set_script(collision_body_script)
		add_child(collision_body)
	
	if floor_notify_area == null or not weakref(floor_notify_area).get_ref():
		floor_notify_area = Area2D.new()
		floor_notify_area.owner = self
		floor_notify_area.name = "FloorNotifyArea"
		floor_notify_area.set_script(floor_setter_script)
		add_child(floor_notify_area)
	
	if collision_body_shape != null:
		collision_body_shape.queue_free()
		collision_body_shape = null
	
	if floor_notify_area_shape != null:
		floor_notify_area_shape.queue_free()
		floor_notify_area_shape = null
	
	collision_body_shape = CollisionPolygon2D.new()
	floor_notify_area_shape = CollisionPolygon2D.new()
	
	for shape in [collision_body_shape, floor_notify_area_shape]:
		shape.name = "CollisionShape"
		shape.owner = self
		var polygon = PoolVector2Array()
		polygon.push_back(collider_edges.top)
		polygon.push_back(collider_edges.right)
		polygon.push_back(collider_edges.bottom)
		polygon.push_back(collider_edges.left)
		polygon.push_back(collider_edges.top)
		shape.polygon = polygon
		shape.set_script(floor_layer_script)
		shape.height = floor_height + height
	
	collision_body.add_child(collision_body_shape)
	floor_notify_area.add_child(floor_notify_area_shape)
	floor_notify_area.height = floor_height + height
	
	collision_body.discover_shapes()

func _generate_collider_edges():
	collider_edges = {
		"left": Vector2(
			-HALF_TILE_WIDTH - ((grid_size.x - 1.0) * HALF_TILE_WIDTH),
			-((grid_size.x - 1.0) * HALF_TILE_HEIGHT)
		),
		"top": Vector2(
			-(HALF_TILE_WIDTH * grid_size.x) + (HALF_TILE_WIDTH * grid_size.y),
			- HALF_TILE_HEIGHT - ((grid_size.x + grid_size.y - 2.0) * HALF_TILE_HEIGHT)
		),
		"bottom": Vector2(
			0.0,
			+ HALF_TILE_HEIGHT
		),
		"right": Vector2(
			HALF_TILE_WIDTH + ((grid_size.y - 1.0) * HALF_TILE_WIDTH),
			-((grid_size.y - 1.0) * HALF_TILE_HEIGHT)
		),
	}

func _queue_generate_region_sprites():
	if not is_queued_generate_region_sprites:
		is_queued_generate_region_sprites = true
		call_deferred("_generate_region_sprites")

func _generate_region_sprites():
	is_queued_generate_region_sprites = false
	
	if region_sprites.size() > 0:
		for tx in region_sprites:
			tx.queue_free()
		region_sprites = []
	
	if not texture:
		return
	
	if region_sprites_y_sort == null or not weakref(region_sprites_y_sort).get_ref() or region_sprites_y_sort.get_parent() != self:
		region_sprites_y_sort = Node2D.new()
		region_sprites_y_sort.owner = self
		add_child(region_sprites_y_sort)
	
	var sort_position = global_position
	var sort_height = floor_height
	if abs(height - floor_height) < 0.1:
		sort_height -= 1
	region_sprites_y_sort.global_position = Vector2(
		global_position.x,
		Global.calculate_y_sort(Vector3(sort_position.x, sort_position.y, sort_height))
	)
	
	var texture_size = texture.get_size()
	var left_of_bottom_corner_width = HALF_TILE_WIDTH + ((grid_size.x - 1.0) * HALF_TILE_WIDTH)
	var right_of_bottom_corner_width = HALF_TILE_WIDTH + ((grid_size.y - 1.0) * HALF_TILE_WIDTH)
	var h_margin = (texture_size.x - (left_of_bottom_corner_width + right_of_bottom_corner_width)) / 2.0
	
	var sprite_center = Vector2(
		h_margin + left_of_bottom_corner_width,
		texture_size.y - HALF_TILE_HEIGHT
	) - texture_offset
	
	var h_coord_length = ceil(grid_size.x) + ceil(grid_size.y)
	var v_coord_length = ceil(texture_size.y / HALF_TILE_HEIGHT)
	var center_coord = ceil(grid_size.x)
	var region_x = 0
	for h_coord in range(0, h_coord_length, 1):
		var region_x_width = HALF_TILE_WIDTH + (h_margin if h_coord == 0 or h_coord == h_coord_length - 1 else 0)
		
		# Pixel offset from the origin of the box object in the sprite for this horizontal slice
		var v_base_offset = (
			abs(h_coord - center_coord + 1 if h_coord - center_coord < -1 else (h_coord - center_coord if h_coord - center_coord > 0 else 0.0)
		) * HALF_TILE_HEIGHT)
		
		# Position of the origin of the box object in the sprite
		var v_sprite_base_offset = (
			texture_size.y - HALF_TILE_HEIGHT - v_base_offset - texture_offset.y
		)
		
		# Pixel offset from the top of the sprite
		var v_sprite_top_offset = (
			v_sprite_base_offset - height
		)
		
		var sprite_y_offset = texture_size.y - HALF_TILE_HEIGHT

		var region_y = 0
		var v_split_coords = [0, v_sprite_top_offset, floor((v_sprite_top_offset + v_sprite_base_offset)/ 2), v_sprite_base_offset, texture_size.y]
		for v_coord_index in range(0, v_split_coords.size() - 1):
			var v_coord = v_split_coords[v_coord_index]
			var region_y_height = v_split_coords[v_coord_index + 1] - v_split_coords[v_coord_index]
			
			var v_offset_from_base = (region_y + region_y_height - v_sprite_base_offset - floor_height)
			var top_clip_sprite_offset = 0.0
			
			if true:
				
				var sprite = Sprite.new()
				sprite.texture = texture
				sprite.centered = false
				sprite.region_enabled = true
				sprite.region_rect = Rect2(region_x, region_y, region_x_width, region_y_height)
				sprite.offset = Vector2(0.0, v_offset_from_base - top_clip_sprite_offset - region_y_height)
				sprite.owner = self
				region_sprites.push_back(sprite)
				region_sprites_y_sort.add_child(sprite)
				sprite.global_position = global_position + Vector2(
					region_x - (h_margin + left_of_bottom_corner_width - texture_offset.x),
					-v_base_offset + top_clip_sprite_offset
				)
			
			region_y += region_y_height
		
		region_x += region_x_width

	Global.print_tree(self)

func _queue_generate_collision_box_preview():
	if not is_queued_generate_collision_box_preview:
		is_queued_generate_collision_box_preview = true
		call_deferred("_generate_collision_box_preview")

func _generate_collision_box_preview():
	is_queued_generate_collision_box_preview = false
	if Engine.editor_hint and preview_collision_box:
		if collision_preview_mesh == null or not weakref(collision_preview_mesh).get_ref():
			collision_preview_mesh = MeshInstance2D.new()
			collision_preview_mesh.owner = self
		var array_mesh = ArrayMesh.new()
		var top_left = collider_edges.left + Vector2(0.0, COLLISION_PREVIEW_DRAW_OFFSET - height - floor_height)
		var top_top = collider_edges.top + Vector2(0.0, COLLISION_PREVIEW_DRAW_OFFSET - height - floor_height)
		var top_bottom = collider_edges.bottom + Vector2(0.0, COLLISION_PREVIEW_DRAW_OFFSET - height - floor_height)
		var top_right = collider_edges.right + Vector2(0.0, COLLISION_PREVIEW_DRAW_OFFSET - height - floor_height)
		var bottom_left = top_left + Vector2(0.0, height)
		var bottom_top = top_top + Vector2(0.0, height)
		var bottom_bottom = top_bottom + Vector2(0.0, height)
		var bottom_right = top_right + Vector2(0.0, height)
		
		# Floor (+Z)
		if floor_height != 0:
			var floor_vertices = PoolVector2Array()
			floor_vertices.push_back(bottom_left + Vector2(0.0, floor_height))
			floor_vertices.push_back(bottom_top + Vector2(0.0, floor_height))
			floor_vertices.push_back(bottom_bottom + Vector2(0.0, floor_height))
			floor_vertices.push_back(bottom_right + Vector2(0.0, floor_height))
			var floor_colors = PoolColorArray()
			floor_colors.push_back(Color(0.0, 0.0, 0.0, 0.35))
			floor_colors.push_back(Color(0.0, 0.0, 0.0, 0.35))
			floor_colors.push_back(Color(0.0, 0.0, 0.0, 0.35))
			floor_colors.push_back(Color(0.0, 0.0, 0.0, 0.35))
			var floor_arrays = []
			floor_arrays.resize(ArrayMesh.ARRAY_MAX)
			floor_arrays[ArrayMesh.ARRAY_VERTEX] = floor_vertices
			floor_arrays[ArrayMesh.ARRAY_COLOR] = floor_colors
			array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, floor_arrays)
		
		# Top (+Z)
		var top_vertices = PoolVector2Array()
		top_vertices.push_back(top_left)
		top_vertices.push_back(top_top)
		top_vertices.push_back(top_bottom)
		top_vertices.push_back(top_right)
		var top_colors = PoolColorArray()
		top_colors.push_back(Color(0.0, 0.0, 1.0, 0.3))
		top_colors.push_back(Color(0.0, 0.0, 1.0, 0.3))
		top_colors.push_back(Color(0.0, 0.0, 1.0, 0.3))
		top_colors.push_back(Color(0.0, 0.0, 1.0, 0.3))
		var top_arrays = []
		top_arrays.resize(ArrayMesh.ARRAY_MAX)
		top_arrays[ArrayMesh.ARRAY_VERTEX] = top_vertices
		top_arrays[ArrayMesh.ARRAY_COLOR] = top_colors
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, top_arrays)
		
		# Left (+Y)
		var left_vertices = PoolVector2Array()
		left_vertices.push_back(top_left)
		left_vertices.push_back(bottom_left)
		left_vertices.push_back(top_bottom)
		left_vertices.push_back(bottom_bottom)
		var left_colors = PoolColorArray()
		left_colors.push_back(Color(0.0, 1.0, 0.0, 0.3))
		left_colors.push_back(Color(0.0, 1.0, 0.0, 0.3))
		left_colors.push_back(Color(0.0, 1.0, 0.0, 0.3))
		left_colors.push_back(Color(0.0, 1.0, 0.0, 0.3))
		var left_arrays = []
		left_arrays.resize(ArrayMesh.ARRAY_MAX)
		left_arrays[ArrayMesh.ARRAY_VERTEX] = left_vertices
		left_arrays[ArrayMesh.ARRAY_COLOR] = left_colors
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, left_arrays)
		
		# Right (+X)
		var right_vertices = PoolVector2Array()
		right_vertices.push_back(top_bottom)
		right_vertices.push_back(bottom_bottom)
		right_vertices.push_back(top_right)
		right_vertices.push_back(bottom_right)
		var right_colors = PoolColorArray()
		right_colors.push_back(Color(1.0, 0.0, 0.0, 0.3))
		right_colors.push_back(Color(1.0, 0.0, 0.0, 0.3))
		right_colors.push_back(Color(1.0, 0.0, 0.0, 0.3))
		right_colors.push_back(Color(1.0, 0.0, 0.0, 0.3))
		var right_arrays = []
		right_arrays.resize(ArrayMesh.ARRAY_MAX)
		right_arrays[ArrayMesh.ARRAY_VERTEX] = right_vertices
		right_arrays[ArrayMesh.ARRAY_COLOR] = right_colors
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, right_arrays)
		
		collision_preview_mesh.mesh = array_mesh
		if not collision_preview_mesh.get_parent():
			add_child(collision_preview_mesh)
		collision_preview_mesh.position = Vector2(0.0, -COLLISION_PREVIEW_DRAW_OFFSET)
		collision_preview_mesh.z_index = 128
	
	else: # Remove collision preview
		if collision_preview_mesh != null and weakref(collision_preview_mesh).get_ref():
			collision_preview_mesh.queue_free()
			collision_preview_mesh = null
