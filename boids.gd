extends Node2D

var Boids 
var StaticObjs
var Target = Vector2(600,600)
const r_flag_finish = 30
onready var flag_target = get_node('Target')

func _ready():
	randomize()
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			Target = event.pos
			flag_target.set_pos(event.pos)

func _on_Button_pressed():
	start()
	
func start():
	Boids = []
	StaticObjs = []
	for boid in get_node('.').get_children():
		if boid.get_name().match('Boid*'):
			#boid.set_pos(Vector2(randi() % 300, randi() % 50))
			boid.Speed = Vector2()
			boid.Target = Target
			Boids.append(boid)
			
	for static_obj in get_node('.').get_children():
		if static_obj.get_name().match('StaticObj*'):
			static_obj.Radius = static_obj.get_texture().size.x / 2
			StaticObjs.append(static_obj)
	set_process(true)
	
func _process(delta):
	set_process_input(false)
	var reg = 0
	for i in range(Boids.size()):
		var boid = Boids[i]
		if boid.Target.distance_to(boid.get_pos()) > r_flag_finish:
			var v1 = Rule1(i)
			var v2 = Rule2(i)
			var v3 = Rule3(i)
			var v4 = Rule4(i)
			var v5 = Rule5(i)
			boid.Speed = boid.Speed + v1 + v2 + v3 + v4 + v5
			boid.set_pos(boid.get_pos()+(boid.Speed))
			boid.Speed = LimitSpeed(boid.Speed)
		else:
			reg += 1
			if reg == Boids.size():
				set_process(false)
				set_process_input(true)
	
func Rule1(boidNum): 
	var massCenter = Vector2(0, 0) 
	var boids = 0 
	var i = 0 
	while i < Boids.size(): 
		#and Boids[i].PlayerId == Boids[boidNum].PlayerId 
		if (i != boidNum and Boids[i].Target == Boids[boidNum].Target):
			massCenter += Boids[i].get_pos()
			boids += 1
		i += 1
	if not(boids): 
		return Vector2(0, 0)
	massCenter /= boids
	return (massCenter - Boids[boidNum].get_pos()) / 160

func Rule2(boidNum): 
	var c = Vector2(0, 0)
	var i = 0
	while i < Boids.size():
		if i != boidNum:
			var distance = Boids[i].get_pos().distance_to(Boids[boidNum].get_pos())
			if distance < 21:
				var direction = Boids[i].get_pos() - Boids[boidNum].get_pos() 
				direction = direction.normalized()
				direction *= (33 - distance)
				c -= direction
		i += 1 
	return c / 35

func Rule3(boidNum): 
	var massCenter = Vector2(0, 0)
	var boids = 0 
	var i = 0
	while i < Boids.size():
		#and Boids[i].PlayerId == Boids[boidNum].PlayerId and 
		if (i != boidNum and Boids[i].Target == Boids[boidNum].Target):
			massCenter += Boids[i].Speed
			boids += 1
		i += 1
	if not(boids):
        return Vector2(0, 0)
	massCenter /= boids
	return (massCenter - Boids[boidNum].Speed) / 18

func Rule4(boidNum): 
	var direction = Boids[boidNum].Target - Boids[boidNum].get_pos() 
	direction = LimitSpeed(direction, 0.85)
	return direction

func Rule5(boidNum):  
	var c = Vector2(0, 0) 
	var i = 0
	while i < StaticObjs.size():
		if (Boids[boidNum].Target != StaticObjs[i].get_pos()):
			var distance = StaticObjs[i].get_pos().distance_to(Boids[boidNum].get_pos()) 
			if (distance < 10.0 + 1.4 * StaticObjs[i].Radius):
				var direction = StaticObjs[i].get_pos() - Boids[boidNum].get_pos() 
				direction = direction.normalized()
				direction *= (18.0 + 1.4 * StaticObjs[i].Radius - distance)
				c -= direction
		i += 1
	return c / 8

func LimitSpeed(speed, limit = 3.5):
	var speedAbs = Vector2(0,0).distance_to(speed)
	if (speedAbs > limit):
		speed = (speed / speedAbs) * limit
	return speed

