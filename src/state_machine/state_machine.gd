class_name StateMachine extends Node

@export var default_state: String
@export var node: Node

var last_state: State
var current_state: State

var states = {}

func _ready() -> void:
	for state in get_children():
		state.state_machine = self
		state.node = node
		states[state.name] = state
	last_state = states[default_state]
	enter_state.call_deferred(default_state)

func _process(delta: float) -> void:
	if current_state:
		current_state.run(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.run_physics(delta)

func enter_state(state_name: String) -> void:
	assert(states.has(state_name), "Tried to swap to nonexistent state: %s" + state_name)
	if current_state:
		current_state.exit()
		last_state = current_state
	current_state = states[state_name]
	current_state.enter()
