extends Node2D

@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var collision_polygon_2d_2 = $StaticBody2D/CollisionPolygon2D2
@onready var polygon_2d_2 = $StaticBody2D/CollisionPolygon2D2/Polygon2D2

func _ready():
	# RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
	polygon_2d.polygon = collision_polygon_2d.polygon
	polygon_2d_2.polygon = collision_polygon_2d_2.polygon

