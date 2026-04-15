extends CharacterBody2D

@export var speed: float = 300.0
@export var damage: int  = 10

@onready var screen_notifier = $ScreenNotifier

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	screen_notifier.screen_exited.connect(_on_screen_exited)

func set_direction(dir: Vector2) -> void:
	direction = dir
	rotation  = dir.angle()

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

	for i in get_slide_collision_count():
		var col      = get_slide_collision(i)
		var collider = col.get_collider()

		if collider == null:
			continue

		if collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			queue_free()
			return

func _on_screen_exited() -> void:
	queue_free()
