extends Node2D
class_name WorldEvents

@export var timer: Timer
@export var notifications: Notifications

var events := ['NOTHING','RAIN', 'FOG', 'SNOW', 'FOLIAGE']

static var current_event: String = 'NOTHING'


func _on_event_timer_timeout() -> void:
	timer.stop()
	var rand = randi_range(0,100)
	if rand > 70:
		current_event = events.slice(1,len(events)).pick_random()
		notifications.text_update('CURRENT EVENT: \n' + current_event)
	else:
		current_event = "NOTHING"
	timer.wait_time = randi_range(360, 700)
	event_start()
	timer.start()


func event_start():
	for particles in get_children():
		if particles is GPUParticles2D:
			particles.emitting = false
			if particles.name == current_event:
				particles.emitting = true
	
	var rand = randi_range(0,100)
	if rand > 70:
		$WIND.emitting = false
	else:
		$WIND.emitting = true
	
