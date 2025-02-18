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
	
	var example_card = ExampleCard.new()
	example_card.position = Vector2(1393.481, 202.9919)
	example_card.get_cell("value").data = "POST /asdas123123123 HTTP/1.1\r\nHost: localhost:8080\r\nAccept-Encoding: gzip, deflate, br\r\nConnection: keep-alive\r\nContent-Length: 10\r\nUser-Agent: HTTPie/3.2.2\r\nAccept: application/json, */*;q=0.5\r\nContent-Type: application/json\r\n\r\n{\"a\": \"a\"}"
	
	var regex_card = RegexCard.new()
	regex_card.position = Vector2(1929.569, 173.417)
	regex_card.get_cell("regex").data = "(?<verb>[^ ]+) (?<name>[^ ]+) HTTP\\/1.1\\r\n(?<headers>[\\S\\s]+)\\r\n\\r\n(?<body>[\\S\\s]*)"
	
	var inspect_card = InspectCard.new()
	inspect_card.position = Vector2(2369.569, 173.417)
	
	var inspect_card_2 = InspectCard.new()
	inspect_card_2.position = Vector2(1463.115, 772.203)
	
	var forward_trigger_card = ForwardTriggerCard.new()
	forward_trigger_card.position = Vector2(4501.917, -434.6002)
	
	on_server_request_card.c_named("peer", parse_http_card)
	parse_http_card.c(example_card)
	example_card.c(regex_card)
	example_card.c(inspect_card_2)
	regex_card.c(inspect_card)
