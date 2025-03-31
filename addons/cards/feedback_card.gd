extends Panel

var current: Tween

func report_object(v):
	%Label.text = str(v)
	if is_inside_tree():
		if current: current.kill()
		current = create_tween()
		current.tween_property(self, "modulate", Color(Color.WHITE, 0.8), 0.4).from(Color(Color.WHITE, 1.0)).set_trans(Tween.TRANS_SINE)
