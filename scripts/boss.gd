extends CharacterBody2D

signal boss_attacked

@export var speed: float    = 80.0
@export var max_health: int = 150
@export var bullet_scene: PackedScene
@export var player_path: NodePath
@export var map_size: Vector2 = Vector2(1920, 1080)

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var shoot_timer: Timer    = $ShootTimer
@onready var walk_sprite: Sprite2D  = $WalkSprite
@onready var shoot_sprite: Sprite2D = $ShootSprite



@onready var player = $"."
var is_shooting: bool    = false
var patrol_points: Array = []
var current_point: int   = 0
var health: int          = 0
var is_alive = true

func _ready() -> void:
	add_to_group("boss")
	health = max_health

	if player_path:
		player = get_node(player_path)

	_build_patrol_points()
	_reset_shoot_timer()
	_show_walk()   # Start in walk state

func _build_patrol_points() -> void:
	patrol_points = [
		Vector2(100, 100),
		Vector2(map_size.x - 100, 100),
		Vector2(map_size.x - 100, map_size.y - 100),
		Vector2(100, map_size.y - 100)
	]

func _show_walk() -> void:
	walk_sprite.visible  = true
	shoot_sprite.visible = false
	anim.play("walk")

func _show_shoot() -> void:
	walk_sprite.visible  = false
	shoot_sprite.visible = true
	anim.play("shoot")

func _physics_process(_delta: float) -> void:
	if is_shooting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Face the player while patrolling
	if player != null:
		if player.global_position.x < global_position.x:
			scale.x = -1
		else:
			scale.x = 1

	var target: Vector2    = patrol_points[current_point]
	var direction: Vector2 = (target - global_position).normalized()

	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(target) < 10.0:
		current_point = (current_point + 1) % patrol_points.size()

func _reset_shoot_timer() -> void:
	shoot_timer.wait_time = randf_range(1.0, 6.0)
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	if player == null:
		_reset_shoot_timer()
		return

	is_shooting = true
	_show_shoot()
	await anim.animation_finished

	emit_signal("boss_attacked")
	_fire_bullet()
	is_shooting = false
	_show_walk()
	_reset_shoot_timer()

func _fire_bullet() -> void:
	if bullet_scene == null or player == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position

	var direction: Vector2 = (player.global_position - global_position).normalized()
	bullet.set_direction(direction)

#func take_damage(_amount: int) -> void:
#	health -= 1
#	if health <= 0:
#		queue_free()
func take_damage(damage: int, _attacker_position: Vector2) -> void:
		health -= damage
		#health_bar.update_health(health)
		if health <= 0:
			_die()

func _die() -> void:
	is_alive = false
	queue_free()
