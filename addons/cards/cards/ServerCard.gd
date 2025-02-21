@tool
extends Card
class_name ServerCard

func v():
	title("Server")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFxJREFUOI3FkzEOACAIA1vj/79cJxKHIhgHOyq9AFVKwovGkxvAdIckbVuSWALC7Iqd7AhdswVIYjbCVQddSJpCF3KMsQMZQB5b6HRfPqQqkRlFN5vfxe9/4T9gAUMgKh+Lum0sAAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["peer", t("StreamPeerTCP")], ["data", t("String")]], [], func (card, peer, data):
		peer.put_string(data)
		peer.disconnect_from_host()
, ["peer"])
	code_card.position = Vector2(3193.317, 1645.337)
	
	var example_card = ExampleCard.new()
	example_card.position = Vector2(1393.481, 202.9919)
	example_card.get_cell("value").data = "POST / HTTP/1.1\r\nHost: localhost:8080\r\nAccept-Encoding: gzip, deflate, br\r\nConnection: keep-alive\r\nContent-Length: 10\r\nUser-Agent: HTTPie/3.2.2\r\nAccept: application/json, */*;q=0.5\r\nContent-Type: application/json\r\n\r\n{\"a\": \"a\"}"
	
	var format_string_card = FormatStringCard.new()
	format_string_card.position = Vector2(2805.796, 1708.315)
	format_string_card.get_cell("string").data = "HTTP/1.1 {status} {status_text}\nContent-Length: 0\nConnection: close\n\n"
	
	var get_property_card = GetPropertyCard.new()
	get_property_card.position = Vector2(2541.791, -471.035)
	get_property_card.get_cell("property_name").data = "content-type"
	
	var get_property_card_2 = GetPropertyCard.new()
	get_property_card_2.position = Vector2(2965.611, 584.8103)
	get_property_card_2.get_cell("property_name").data = "body"
	
	var if_card = IfCard.new()
	if_card.position = Vector2(2589.533, 437.2175)
	
	var inspect_card = InspectCard.new()
	inspect_card.position = Vector2(1310.254, 946.3888)
	
	var inspect_card_2 = InspectCard.new()
	inspect_card_2.position = Vector2(3590.185, 1399.205)
	
	var on_server_request_card = OnServerRequestCard.new()
	on_server_request_card.position = Vector2(301.9791, 300.826)
	on_server_request_card.get_cell("server").data = null
	on_server_request_card.get_cell("port").data = 8080
	
	var parse_headers_card = ParseHeadersCard.new()
	parse_headers_card.position = Vector2(2136.226, -328.334)
	
	var parse_http_card = ParseHttpCard.new()
	parse_http_card.position = Vector2(740.0, 300.0)
	
	var parse_json_card = ParseJsonCard.new()
	parse_json_card.position = Vector2(2965.951, 1103.504)
	
	var regex_card = RegexCard.new()
	regex_card.position = Vector2(1925.457, 141.1403)
	regex_card.get_cell("regex").data = "(?<verb>[^ ]+) (?<name>[^ ]+) HTTP\\/1.1\\r\n(?<headers>[\\S\\s]+)\\r\n\\r\n(?<body>[\\S\\s]*)"
	
	var string_equal_card = StringEqualCard.new()
	string_equal_card.position = Vector2(2951.199, -188.7985)
	string_equal_card.get_cell("value").data = "application/json"
	
	example_card.c(regex_card)
	example_card.c(inspect_card)
	format_string_card.c_named("data", code_card)
	get_property_card.c(string_equal_card)
	get_property_card_2.c(parse_json_card)
	if_card.c(get_property_card_2)
	on_server_request_card.c_named("peer", parse_http_card)
	on_server_request_card.c_named("peer", code_card)
	on_server_request_card.lock(code_card)
	parse_headers_card.c(get_property_card)
	parse_http_card.c(example_card)
	parse_json_card.c(format_string_card)
	parse_json_card.c(inspect_card_2)
	regex_card.c(parse_headers_card)
	regex_card.c(if_card)
	string_equal_card.c(if_card)
