extends Node

@onready var catmunch = $CatMunchy
@onready var catyummy = $CatYummy
@onready var huh_cat = $HuhCat

func _ready():
	catmunch.play("eat")
	catyummy.play("chew")
	huh_cat.play("huh")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels_Folder/level_1.tscn")

func _on_quit_pressed():
	get_tree().quit()
