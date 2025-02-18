@tool
extends Card
class_name ServerCard

func v():
	title("Server")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFxJREFUOI3FkzEOACAIA1vj/79cJxKHIhgHOyq9AFVKwovGkxvAdIckbVuSWALC7Iqd7AhdswVIYjbCVQddSJpCF3KMsQMZQB5b6HRfPqQqkRlFN5vfxe9/4T9gAUMgKh+Lum0sAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var on_server_request_card = OnServerRequestCard.new()
	on_server_request_card.position = Vector2(300.0, 300.0)
	on_server_request_card.get_cell("server").data = null
	on_server_request_card.get_cell("port").data = 8080
	
	var parse_http_card = ParseHttpCard.new()
	parse_http_card.position = Vector2(740.0, 300.0)
	
	on_server_request_card.c_named("peer", parse_http_card)
