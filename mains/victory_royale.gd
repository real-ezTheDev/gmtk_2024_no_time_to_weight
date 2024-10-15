class_name VictoryRoyale extends Node2D


func start():
	$PlayerCharacter.victory_royale()
	$GPUParticles2D.emitting = true
