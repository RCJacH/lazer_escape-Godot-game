extends Label


func _on_lazer_angle_changed(new_angle: float):
	var angle := rad_to_deg(new_angle + PI * 0.5)
	if angle < 0.0:
		angle += 360.0
	text = "Angle: %f" % angle
