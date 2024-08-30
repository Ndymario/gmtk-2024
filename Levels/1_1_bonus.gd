extends Node2D
var clear = false

func _ready() -> void:
	var tilemap: TileMapLayer = get_node("TileMapLayer")
	var tileset: TileSetAtlasSource = tilemap.tile_set.get_source(0)
	tileset.texture = load("res://Tilesets/Underground/tileset_orange.png")
	$AudioStreamPlayer2D.stream = load("res://Audio/Music/Underground.ogg")
	$AudioStreamPlayer2D.play()

func _physics_process(delta: float) -> void:
	if !clear:
		$AudioStreamPlayer2D.position = $Player.position
	else:
		$AudioStreamPlayer2D.position.y += 300
	if !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()



func _on_player_clear() -> void:
	clear = true
