extends Node2D

signal detected(object: Node2D)

@export var included_groups: Array[String] = []
@export var excluded_groups: Array[String] = []
@export var degrees = 30
@export var distance = 256:
	set(v):
		distance = v
		$RayCast2D.target_position = Vector2(0, distance)
		update_texture()
	get:
		return distance

func _ready() -> void:
	# cause one update
	distance = distance

func update_texture() -> void:
	print(distance)
	var viewport = SubViewport.new()
	RenderingServer.viewport_set_active(viewport.get_viewport_rid(), true)
	add_child(viewport)
	viewport.size = Vector2i(distance * 2, distance * 2)
	var circle_sector = preload("res://circle_sector.tscn").instantiate()
	circle_sector.radius = viewport.size.x / 2
	circle_sector.position = viewport.size / 2
	circle_sector.degrees = degrees
	viewport.add_child(circle_sector)
	var image = await render_subviewport(viewport)
	$PointLight2D.texture = ImageTexture.create_from_image(image)
	viewport.queue_free()

func render_subviewport(subviewport: SubViewport) -> Image:
	var scene_tree = Engine.get_main_loop() as SceneTree
	var root_viewport = scene_tree.root.get_viewport_rid()
	RenderingServer.viewport_set_active(root_viewport, false)
	
	RenderingServer.viewport_set_update_mode(subviewport.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ONCE)
	RenderingServer.force_draw()
	RenderingServer.viewport_set_active(root_viewport, true)
	await RenderingServer.frame_post_draw
	return subviewport.get_texture().get_image()

func _physics_process(_delta: float) -> void:
	var hit = {}
	for offset in range(degrees * -0.5, degrees * 0.5):
		$RayCast2D.rotation_degrees = 180 + offset
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			if not hit.get(collider):
				hit[collider] = true
				if collider is Node2D \
						and included_groups.any(func(group): collider.is_in_group(group)) \
						and excluded_groups.all(func(group): not collider.is_in_group(group)):
					detected.emit(collider)
