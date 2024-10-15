@tool
class_name BodyPartSprite extends Sprite2D

const TILE_SIZE: int = 16

@export var part: int = 0:
	set(value):
		part=value
		set_region_rect(Rect2(TILE_SIZE*index, TILE_SIZE*part, TILE_SIZE, TILE_SIZE))
@export var index: int = 0:
	set(value):
		index=value
		set_region_rect(Rect2(TILE_SIZE*index, TILE_SIZE*part, TILE_SIZE, TILE_SIZE))
