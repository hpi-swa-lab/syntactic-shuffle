@tool
extends Card
class_name AxisControlsCard

func v():
	title("Axis Controls")
	description("Emits signals for inputs on the four axes.")
	icon_data("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAHdJREFUOI3dUjEKwCAQi6V/08G+th30dekgHloMFRwKzXKYCyFGga/hBM9Z/a6co/fd+cp5qNuUwZlSNxWkwSoYvSdJmxC9OLWYxQaUwkiCpJXXciXAWAcAFrWNW1F5dS17xmfbRwgd75z6Mi8J6q5N0HLLJf4AN3DOhmgmhQv2AAAAAElFTkSuQmCC")
	container_size(Vector2(2000.0, 1600.0))

func s():
	var out_card = OutCard.new()
	out_card.position = Vector2(1190.92, 400.0026)
	var code_card = CodeCard.create([["trigger", trg()]], [["out", cmd("direction", t("Vector2"))]], func(card, out):
		var input_direction = Vector2.ZERO
		if Input.is_action_pressed("ui_left"): input_direction += Vector2.LEFT
		if Input.is_action_pressed("ui_right"): input_direction += Vector2.RIGHT
		if Input.is_action_pressed("ui_up"): input_direction += Vector2.UP
		if Input.is_action_pressed("ui_down"): input_direction += Vector2.DOWN
		if input_direction.length() > 0: out.call(input_direction.normalized())
, [])
	code_card.position = Vector2(581.647, 398.63)
	var physics_process_card = PhysicsProcessCard.new()
	physics_process_card.position = Vector2(200.0, 400.0)
	
	code_card.c(out_card)
	physics_process_card.c_named("trigger", code_card)
