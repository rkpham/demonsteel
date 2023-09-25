class_name State extends Node

var node: Node
var state_machine: StateMachine

## Called when a state is entered.
func enter() -> void:
	pass

## Called in state machine's _process function.
func run(delta) -> void:
	pass

## Called in state machine's _physics_process function.
func run_physics(delta) -> void:
	pass

## Called when the state exits.
func exit() -> void:
	pass
