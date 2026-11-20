@tool
extends Node

const default_duration: float = 0.31
const default_distance: float = 100.0

func _init() -> void: self.process_mode = Node.PROCESS_MODE_ALWAYS

#region Basic Animations

func pop(node: Control, pop_scale := Vector2(0.5,0.5), base_scale := Vector2.ONE, final_scale := Vector2.ONE, duration: float = default_duration, transition := Tween.TRANS_QUAD, easing := Tween.EASE_IN_OUT) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	if not is_instance_valid(node):
		return get_tree().process_frame
	
	node.offset_transform_enabled = true
	var prev_pivot: Vector2 = node.offset_transform_pivot_ratio
	node.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	
	var tween := new_tween(node, &"offset_transform_scale", Tween.TRANS_SINE, Tween.EASE_OUT)
	var pop_duration := duration * 0.6
	var settle_duration := duration * 0.4
	
	tween.tween_property(node, "offset_transform_scale", final_scale + pop_scale, pop_duration).from(base_scale)
	tween.tween_property(node, "offset_transform_scale", final_scale, settle_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	tween.finished.connect(func(): 
		if is_instance_valid(node): 
			node.offset_transform_pivot_ratio = prev_pivot
	)
	return tween.finished

func scale(node: Control, target_scale: Vector2, duration: float = default_duration, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	if not is_instance_valid(node):
		return get_tree().process_frame
	
	node.offset_transform_enabled = true
	node.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	
	var tween := new_tween(node, &"offset_transform_scale", transition, easing)
	tween.tween_property(node, "offset_transform_scale", target_scale, duration)
	
	return tween.finished

#endregion

#region Transitions

func fade_in(node: Control, duration := default_duration, from := 0.0, to := 1.0, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node, &"modulate")
	if not is_instance_valid(node):
		return get_tree().process_frame
	if node: node.tree_exiting.connect(func(): _faded_nodes.erase(node))
	_faded_nodes[node] = to
	var tween := new_tween(node,&"modulate", transition, easing)
	tween.tween_property(node, "modulate:a", to, duration).from(from)
	return tween.finished

func fade_out(node: Control, duration := default_duration, from := node.modulate.a, to := 0.0, transition := Tween.TRANS_CUBIC, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node,&"modulate")
	if not is_instance_valid(node):
		return get_tree().process_frame
	if from == 0.0: from = 1.0
	_faded_nodes[node] = from
	if node: node.tree_exiting.connect(func(): _faded_nodes.erase(node))
	var tween := new_tween(node,&"modulate", transition, easing)
	tween.tween_property(node, "modulate:a", to, duration).from(from)
	return tween.finished

func pop_in(node: Control, duration := default_duration, to := Vector2.ONE, from := Vector2(0.5,0.5), fade_from: float = 0.0, fade_to: float = 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	if not is_instance_valid(node):
		return get_tree().process_frame
	var tween := new_tween(node, &"offset_transform_scale", transition, easing)
	if not is_instance_valid(node): return tween.finished
	var duration_scale := duration / default_duration
	fade_in(node, 0.3 * duration_scale, fade_from, fade_to)
	pop(node,Vector2(0.2,0.2),from,to,duration)
	return tween.finished
	node.offset_transform_enabled = true
	var prev_pivot_offset_ratio: Vector2 = node.offset_transform_pivot_ratio
	node.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	
	tween.tween_property(node, "offset_transform_scale", to, duration).from(from)
	tween.finished.connect(func(): if is_instance_valid(node): node.offset_transform_pivot_ratio = prev_pivot_offset_ratio)
	return tween.finished

func pop_out(node: Control, duration := default_duration, to := Vector2.ZERO, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	if not is_instance_valid(node):
		return get_tree().process_frame
	var tween := new_tween(node, &"offset_transform_scale", transition, easing)
	if not is_instance_valid(node): return tween.finished
	var duration_scale := duration / default_duration
	fade_out(node, 0.25 * duration_scale)
	
	node.offset_transform_enabled = true
	var prev_pivot_offset_ratio: Vector2 = node.offset_transform_pivot_ratio
	var prev_scale: Vector2 = node.offset_transform_scale
	node.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	
	tween.tween_property(node, "offset_transform_scale", to, duration)
	tween.tween_callback(func(): 
		if is_instance_valid(node): 
			node.offset_transform_pivot_ratio = prev_pivot_offset_ratio
			node.offset_transform_scale = prev_scale
	)
	return tween.finished

func fade_from_left(node: Control, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.LEFT, fade_from, fade_to, transition, easing)
func fade_from_right(node: Control, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.RIGHT, fade_from, fade_to, transition, easing)
func fade_from_up(node: Control, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.UP, fade_from, fade_to, transition, easing)
func fade_from_down(node: Control, duration := default_duration, distance := default_distance, fade_from := 0.0, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal: return fade_slide(node, duration, -distance * Vector2.DOWN, fade_from, fade_to, transition, easing)

func fade_to_left(node: Control, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.LEFT, fade_from, fade_to, transition, easing)
func fade_to_right(node: Control, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.RIGHT, fade_from, fade_to, transition, easing)
func fade_to_up(node: Control, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.UP, fade_from, fade_to, transition, easing)
func fade_to_down(node: Control, duration := default_duration, distance := default_distance, fade_from := 1.0, fade_to := 0.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal: return fade_slide(node, duration, distance * Vector2.DOWN, fade_from, fade_to, transition, easing)

func fade_slide(node: Control, duration := default_duration, slide_distance := Vector2.ZERO, fade_from := node.modulate.a, fade_to := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
	_check_active_animations(node, &"position") ## No need to use await here.
	if not is_instance_valid(node):
		return get_tree().process_frame
	var fading_in := fade_to >= fade_from
	var fade_func: String = "fade_in" if fading_in else "fade_out"
	call(fade_func, node, duration, fade_from, fade_to)
	
	node.offset_transform_enabled = true
	var tween := new_tween(node,&"position", transition, easing)
	
	if fading_in:
		tween.tween_property(node, "offset_transform_position", Vector2.ZERO, duration).from(slide_distance)
	else:
		tween.tween_property(node, "offset_transform_position", slide_distance, duration).from(Vector2.ZERO)
		tween.finished.connect(func(): if is_instance_valid(node): node.offset_transform_position = Vector2.ZERO)
		
	return tween.finished

#endregion

#region Other Animations

var _active_animations: Dictionary
var _faded_nodes: Dictionary[Node, float]
var _scaled_nodes: Dictionary[Node, Vector2]

func pulse(node: Control, amount := 2, duration: float = default_duration, opacity_off := 0.5, opacity_in := 1.0, transition := Tween.TRANS_BACK, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node, &"modulate")
	if not is_instance_valid(node):
		return get_tree().process_frame
	#if amount < 0: return null
	var base_modulate := node.modulate.a
	var tween := new_tween(node, &"modulate", Tween.TRANS_SINE)
	var pulse_duration := duration / 2.0
	tween.set_loops(amount)
	
	tween.tween_property(node, "modulate:a", opacity_off, pulse_duration)
	tween.tween_property(node, "modulate:a", opacity_in, pulse_duration)
	tween.finished.connect(func(): if is_instance_valid(node): node.modulate.a = base_modulate)
	return tween.finished

func ping(node: Control, target_modulate: Color = Color(3.294, 0.0, 0.0, 1.0), duration := default_duration, scale_amount := Vector2(0.1, 0.1), transition := Tween.TRANS_CIRC, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	if not is_instance_valid(node):
		return get_tree().process_frame
	await _check_active_animations(node, &"modulate")
	if not is_instance_valid(node):
		return get_tree().process_frame

	node.offset_transform_enabled = true
	node.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	var start_scale: Vector2 = node.offset_transform_scale
	var start_modulate := node.modulate
	var to := start_scale + scale_amount
	var tween := new_tween(node, &"offset_transform_scale", transition, easing)
	var ping_in_duration := duration * 0.3
	var reset_duration := duration - ping_in_duration
	
	tween.set_parallel(true)
	tween.tween_property(node, "modulate", target_modulate, ping_in_duration / 3.0)
	tween.tween_property(node, "offset_transform_scale", +scale_amount, ping_in_duration).as_relative()
	tween.set_parallel(false)
	
	tween.finished.connect(func(): 
		if is_instance_valid(node):
			node.offset_transform_scale = start_scale
			node.modulate = start_modulate
		if tween: tween.stop()
	)
	
	tween.tween_property(node, "offset_transform_scale", node.offset_transform_scale-start_scale-scale_amount, reset_duration).as_relative()
	tween.tween_property(node, "modulate", start_modulate, reset_duration)
	return tween.finished

func wiggle(node: Control, degrees := 2.5, duration := default_duration, amount := 2, transition := Tween.TRANS_SINE, easing := Tween.EASE_IN) -> Signal:
	await _check_active_animations(node, &"rotation")
	if not is_instance_valid(node):
		return get_tree().process_frame
	
	node.offset_transform_enabled = true
	var start_rotation: float = node.offset_transform_rotation
	var prev_pivot_offset_ratio: Vector2 = node.offset_transform_pivot_ratio
	node.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	var rad_offset := deg_to_rad(degrees)
	
	var tween := new_tween(node, &"rotation", transition, easing).set_loops(amount)
	tween.set_parallel(false)
	tween.tween_property(node, "offset_transform_rotation", start_rotation + rad_offset, duration / 4.0)
	tween.tween_property(node, "offset_transform_rotation", start_rotation - rad_offset, duration / 2.0)
	tween.tween_property(node, "offset_transform_rotation", start_rotation, duration / 4.0)
	
	tween.finished.connect(func(): 
		if is_instance_valid(node): 
			node.offset_transform_rotation = start_rotation
			node.offset_transform_pivot_ratio = prev_pivot_offset_ratio
	)
	return tween.finished

func hover_in(node: Control, duration := default_duration, from := Vector2.ONE, scale_amount := Vector2(0.08, 0.08), transition := Tween.TRANS_CUBIC, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	var start_scale := node.offset_transform_scale
	var tween := new_tween(node, &"offset_transform_scale", transition, easing)
	tween.tween_property(node, "offset_transform_scale", (from + scale_amount)  , duration * 0.6)
	return tween.finished

func hover_out(node: Control, duration := default_duration, to := Vector2.ONE, from := node.offset_transform_scale, transition := Tween.TRANS_BACK, easing := Tween.EASE_OUT) -> Signal:
	await _check_active_animations(node, &"offset_transform_scale")
	var start_scale := node.offset_transform_scale
	var tween := new_tween(node, &"offset_transform_scale", transition, easing)
	#tween.tween_property(node, "offset_transform_scale", to * Vector2( 0.95,  1.015) , duration * 0.4)
	tween.tween_property(node, "offset_transform_scale", to , duration)
	return tween.finished

#endregion

#region Helper Functions

func _check_active_animations(node: Node, anim_key: StringName) -> void:
	if node is Control: node.offset_transform_enabled = true
		 
	var should_await := false
	if anim_key == &"modulate" and _faded_nodes.has(node):
		if node is CanvasItem:
			node.modulate.a = _faded_nodes[node]
		_faded_nodes.erase(node)
		should_await = true
	if anim_key == &"offset_transform_scale" and _scaled_nodes.has(node):
		if node is CanvasItem:
			node.offset_transform_scale = _scaled_nodes[node]
		_scaled_nodes.erase(node)
		should_await = true
	if _active_animations.has(node) and _active_animations[node].has(anim_key):
		var active_tween: Tween = _active_animations[node][anim_key]
		if is_instance_valid(active_tween) and active_tween.is_valid():
			active_tween.stop()
			active_tween.finished.emit()
		if _active_animations.has(node):
			_active_animations[node].erase(anim_key)
			if _active_animations[node].is_empty():
				_active_animations.erase(node)
		should_await = true
		
	if should_await: await get_tree().process_frame

func new_tween(parent_node: Node, anim_key: StringName, transition := Tween.TRANS_LINEAR, easing := Tween.EASE_IN) -> Tween:

	if not is_instance_valid(parent_node): parent_node = get_tree().current_scene
	var tween := parent_node.create_tween().set_trans(transition).set_ease(easing).set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	
	if not _active_animations.has(parent_node):
		_active_animations[parent_node] = {}
	_active_animations[parent_node][anim_key] = tween
	
	tween.finished.connect(func(): 
		if _active_animations.has(parent_node) and _active_animations[parent_node].get(anim_key) == tween:
			_active_animations[parent_node].erase(anim_key)
			if _active_animations[parent_node].is_empty():
				_active_animations.erase(parent_node)
	)
	return tween

#endregion
