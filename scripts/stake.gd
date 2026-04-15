extends Area2D

@export var speed : int = 300
@export var strength = 50

var direction : Vector2

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * speed * delta

func destroy():
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	destroy()


func _on_body_entered(body: Node2D) -> void:
	body.take_damage(strength, position)
	destroy()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
