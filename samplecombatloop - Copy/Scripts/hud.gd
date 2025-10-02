class_name HUD
extends CanvasLayer


func hide_hud():
	$Slash.hide()
	$Heal.hide()
	
func reveal_hud():
	$Slash.show()
	$Heal.show()
	
