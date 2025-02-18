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
	regex_card.position = Vector2(1925.457, 141.1403)
	regex_card.get_cell("regex").data = "(?<verb>[^ ]+) (?<name>[^ ]+) HTTP\\/1.1\\r\n(?<headers>[\\S\\s]+)\\r\n\\r\n(?<body>[\\S\\s]*)"
	
	var inspect_card = InspectCard.new()
	inspect_card.position = Vector2(1463.115, 772.203)
	
	var parse_headers_card = ParseHeadersCard.new()
	parse_headers_card.position = Vector2(2136.226, -328.334)
	
	var inspect_card_2 = InspectCard.new()
	inspect_card_2.position = Vector2(4073.443, 990.723)
	
	var get_property_card = GetPropertyCard.new()
	get_property_card.position = Vector2(2690.887, -457.1656)
	get_property_card.get_cell("property_name").data = "content-type"
	
	var string_equal_card = StringEqualCard.new()
	string_equal_card.position = Vector2(2951.199, -188.7985)
	string_equal_card.get_cell("value").data = "application/json"
	
	var get_property_card_2 = GetPropertyCard.new()
	get_property_card_2.position = Vector2(2936.088, 750.2141)
	get_property_card_2.get_cell("property_name").data = "body"
	
	var parse_json_card = ParseJsonCard.new()
	parse_json_card.position = Vector2(3454.84, 936.5349)
	
	var if_card = IfCard.new()
	if_card.position = Vector2(2589.533, 437.2175)
	
	on_server_request_card.c_named("peer", parse_http_card)
	parse_http_card.c(example_card)
	example_card.c(regex_card)
	example_card.c(inspect_card)
	regex_card.c(parse_headers_card)
	regex_card.c(if_card)
	parse_headers_card.c(get_property_card)
	get_property_card.c(string_equal_card)
	string_equal_card.c(if_card)
	get_property_card_2.c(parse_json_card)
	parse_json_card.c(inspect_card_2)
	if_card.c(get_property_card_2)
