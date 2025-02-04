@tool
extends Card
class_name ParseHttpCard

func v():
	title("Parse HTTP")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAEtJREFUOI1j/P//PwMlgIki3VDwH+oKOA3DxPAxXPD//39GfDQ6m4mBgYGBkZGRpIBAVs+EbiIx4P///4wwPRQHIuOAR+OoAcPCAADhijnxQkPnegAAAABJRU5ErkJggg==")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var code_card = CodeCard.create([["peer", t("StreamPeerTCP")]], {"out": t("String")}, func (card, peer):
		var data = peer.get_utf8_string(peer.get_available_bytes())
		card.output("out", [data])
, [])
	code_card.position = Vector2(842.5, 541.0)
	var named_in_card = NamedInCard.named_data("peer", t("StreamPeerTCP"))
	named_in_card.position = Vector2(249.7198, 462.3833)
	var out_card = OutCard.new()
	out_card.position = Vector2(1434.851, 531.6228)
	
	code_card.c(out_card)
	named_in_card.c_named("peer", code_card)
