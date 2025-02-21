extends Node2D
class_name CardLock

static var pending_lock: CardLock

static func create(a: Card, b: Card):
	if pending_lock and pending_lock.a == a and pending_lock.b == b:
		return
	if pending_lock: pending_lock.queue_free()
	pending_lock = CardLock.new(a, b)

static func abort_lock():
	if pending_lock: pending_lock.queue_free()
	pending_lock = null

var a: Card
var b: Card
var unlock = false

var progress = 0.0:
	get: return progress
	set(v):
		progress = v
		queue_redraw()

func _init(a: Card, b: Card) -> void:
	self.a = a
	self.b = b
	
	unlock = a.locked.has(b)
	progress = 1.0 if unlock else 0.0
	
	scale = Vector2(5, 5)
	z_index = 100
	Card.set_ignore_object(self)
	a.get_parent().add_child(self)
	position = (a.position + b.position) / 2.0

func _ready() -> void:
	var t = create_tween()
	t.tween_property(self, "progress", 0.0 if unlock else 1.0, 1.6).set_delay(0.25)
	t.finished.connect(func ():
		# hide but remain active such that we do not try to re-lock right away
		visible = false
		a.unlock(b) if unlock else a.lock(b))

func _draw() -> void:
	var t = preload("res://addons/cards/icons/padlock.png")
	draw_texture(t, t.get_size() / -2)
	draw_arc(Vector2.ZERO, 16, 0, progress * PI * 2, 64, Color.AQUAMARINE, 8, false)

func _process(delta: float) -> void:
	if a.global_position.distance_to(b.global_position) > Card.MAX_LOCK_DISTANCE:
		abort_lock()
