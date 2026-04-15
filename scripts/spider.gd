extends CharacterBody2D

@export var KNOCKBACK_FORCE = .5
@export var SPEED = 200.0
var is_alive = true
var health: int = 50
var strength: int = 10
var target = null
var target_in_range: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Node2D = $HealthBar
@onready var attack_timer: Timer = $AttackTimer

func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("move")
	


func take_damage(damage: int, attacker_position: Vector2) -> void:
		health -= damage
		health_bar.update_health(health)
		if health <= 0:
			_die()
		else:
			var knockback_direction = (position - attacker_position).normalized()
			var target_position = position * knockback_direction * KNOCKBACK_FORCE
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "position", target_position, 0.5)
			

func _die() -> void:
	is_alive = false
	queue_free()
	
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Hero":
		target = body
		print("target dectected")

func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Hero":
		target = null
		print("target lost")
		animated_sprite_2d.play("move")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Hero":
		target_in_range = true
		body.take_damage(strength)
		attack_timer.start()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Hero":
		target_in_range = false
		attack_timer.stop()
	
func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)
