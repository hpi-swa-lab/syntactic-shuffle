extends Node2D

func _ready() -> void:
	var radius = $SubViewport/CircleSector.radius
	var degrees = $SubViewport/CircleSector.degrees
	$SubViewport.size = Vector2i(radius * 2, radius * 2)
	$SubViewport/CircleSector.position = Vector2(radius, radius)
	RenderingServer.viewport_set_active($SubViewport.get_viewport_rid(), true)
	var image = await render_subviewport($SubViewport)
	image.save_png("res://resources/circle_sector/radius_{radius}_degrees_{degrees}.png".format({"radius": radius, "degrees": degrees}))

func render_subviewport(subviewport: SubViewport) -> Image:
	var scene_tree = Engine.get_main_loop() as SceneTree
	var root_viewport = scene_tree.root.get_viewport_rid()
	RenderingServer.viewport_set_active(root_viewport, false)
	
	RenderingServer.viewport_set_update_mode(subviewport.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_ONCE)
	RenderingServer.force_draw()
	RenderingServer.viewport_set_active(root_viewport, true)
	await RenderingServer.frame_post_draw
	return subviewport.get_texture().get_image()
