extends CharacterBody2D

signal died

var SPEED = 300.0
var is_attacking = false
var max_health: int
var health: int
var alive: bool = true
var strength:int = 20


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var hand = $Hand

@export var ref_stake : PackedScene


func _ready() -> void:	
	health = PlayerStats.health
	max_health = PlayerStats.max_health


func _physics_process(_delta: float) -> void:
	if alive:
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()
		if is_attacking:
			velocity = Vector2.ZERO
			return
		process_movement()
		move_and_slide()

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	play_animation(direction)

func process_animation() -> void:
	if is_attacking:
		return

func play_animation(dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play("idle")
	if dir.y < 0:
		animated_sprite_2d.play("idle")
	if dir.y > 0:
		animated_sprite_2d.play("idle")

func attack() -> void:
	is_attacking = true
	animated_sprite_2d.play("attack")
	if ref_stake:
		var stake = ref_stake.instantiate()
		get_tree().current_scene.add_child(stake)
		stake.global_position = self.global_position
		var stake_rotation = self.global_position.direction_to(get_global_mouse_position()).angle()
		stake.rotation = stake_rotation
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
	animated_sprite_2d.play("idle")

func take_damage(amount: int) -> void:
	if alive:
		if damage_cooldown.time_left > 0:
			return
		health -= amount
		PlayerStats.health = health
		print(health)
#		player_stats.health = health
		if health <= 0:
			die()
		damage_cooldown.start()

func die() -> void:
	alive = false
	$".".hide()
	died.emit()
	
