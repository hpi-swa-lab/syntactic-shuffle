@tool
extends Card
class_name OnServerRequestCard

func v():
	title("On TCP Request")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGNJREFUOI3FkkkOwDAIA23U/3/ZPRFZVbNAD/U1YTJGIQDBIokoJHKoOpi5AICkdheXgLToAEaFrkW4wQoyO6N09nACnlUHoFLBIbG6uLNpAzwtgFf4vMSSwdtnOzaY5Z8lem7AVDYNBwuVMgAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var cell_card = CellCard.create("server", "TCPServer", null)
	cell_card.position = Vector2(571.4874, 360.6539)
	
	var code_card = CodeCard.create([["[trigger]", trg()], ["server", t("Object")], ["port", t("int")]], [["server", cmd("store", t("TCPServer"))], ["peer", t("StreamPeerTCP")]], func(card, out_server, out_peer, server, port):
		if not server:
			server = TCPServer.new()
			server.listen(port)
			out_server.call(server)
		if server.is_connection_available():
			var peer = server.take_connection()
			out_peer.call(peer)
, ["server", "port"])
	code_card.position = Vector2(906.1457, 972.6456)
	
	var store_card = StoreCard.new()
	store_card.position = Vector2(1265.443, 461.618)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(1697.662, 1155.92)
	
	var filter_signatures_card = FilterSignaturesCard.new(t("StreamPeerTCP"))
	filter_signatures_card.position = Vector2(1325.512, 1241.675)
	
	var cell_card_2 = CellCard.create("port", "int", 8080)
	cell_card_2.position = Vector2(269.1928, 589.1631)
	
	var always_card = AlwaysCard.new()
	always_card.position = Vector2(456.0802, 1383.875)
	
	cell_card.c_named("server", code_card)
	code_card.c(store_card)
	code_card.c(filter_signatures_card)
	store_card.c(cell_card)
	filter_signatures_card.c(out_card)
	cell_card_2.c_named("port", code_card)
	always_card.c_named("[trigger]", code_card)
