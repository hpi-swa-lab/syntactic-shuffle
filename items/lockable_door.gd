extends Node2D

@export var is_locked = true
var is_closed = true

var USE_ROTATION_RADIANS = 0.5 * PI

func open_door():
	if not is_closed or is_locked: return
	self.rotate(USE_ROTATION_RADIANS)
	is_closed = false
	
func close_door():
	if is_closed: return
	self.rotate(-USE_ROTATION_RADIANS)
	is_closed = true
	
func use():
	if is_closed:
		open_door()
	else:
		close_door()

func lock_or_unlock_door():
	if is_locked:
		open_door()
	else:
		close_door()
	is_locked = not is_locked
		
func unlock_door():
	is_locked = false
	open_door()

func lock_door():
	is_locked = true
	close_door()
	

		
		
