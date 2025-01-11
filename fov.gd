extends Node2D

signal spots(object: Object)

@export var degrees = 30

func _ready() -> void:
	var viewport = SubViewport.new()
	RenderingServer.viewport_set_active(viewport.get_viewport_rid(), true)
	add_child(viewport)
	viewport.size = Vector2i(1024, 1024)
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

func _physics_process(delta: float) -> void:
	var hit = {}
	for offset in range(degrees * -0.5, degrees * 0.5):
		$RayCast2D.rotation_degrees = 180 + offset
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			if not hit.get(collider):
				hit[collider] = true
				spots.emit(collider)
