@tool
extends Card
class_name ParseHeadersCard

func v():
	title("Parse Headers")
	description("")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAFFJREFUOI3tUkEKADAI0rH/f9mdgohGRJcdJnQoyjSiJEywRtNPEGwAIClJtGLMfT0l6CAuKi1kW1MFt8bMisfyjRYdBaWFSkH7iFER/yvPCQ5ObCYhPaHX4wAAAABJRU5ErkJggg==")
	container_size(Vector2(2419.082, 952.4449))

func s():
	var get_property_card = GetPropertyCard.new()
	get_property_card.position = Vector2(519.6938, 524.0811)
	get_property_card.get_cell("property_name").data = "headers"
	
	var split_card = SplitCard.new()
	split_card.position = Vector2(905.5367, 710.232)
	split_card.get_cell("separator").data = "\n"
	
	var regex_card = RegexCard.new()
	regex_card.position = Vector2(1351.268, 508.6866)
	regex_card.get_cell("regex").data = "(?<name>[^ ]+):\\s*(?<value>[^ ]+)"
	
	var in_card = InCard.data(t("Dictionary"))
	in_card.position = Vector2(100.0, 400.0)
	
	var out_card = OutCard.new(false)
	out_card.position = Vector2(2190.227, 358.5387)
	
	var code_card = CodeCard.create([["list", it(t("Dictionary"))]], [["out", t("Dictionary")]], func (card, out, list):
		var dict = {}
		for item in list:
			dict[item["name"].to_lower()] = item["value"]
		out.call(dict)
, [])
	code_card.position = Vector2(1785.021, 454.5419)
	
	get_property_card.c(split_card)
	split_card.c(regex_card)
	regex_card.c_named("list", code_card)
	in_card.c(get_property_card)
	code_card.c(out_card)
