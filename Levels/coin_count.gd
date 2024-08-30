extends CanvasLayer

var coins: int
var ones_place: TextureRect
var tens_place: TextureRect

var number_regions = [Rect2(6, 1, 21, 30), Rect2(43, 1, 12, 30), Rect2(70, 2, 21, 29), Rect2(106, 1, 22, 30), Rect2(143, 1, 23, 31), Rect2(182, 1, 18, 29), Rect2(216, 1, 19, 30), Rect2(250, 1, 22, 30), Rect2(287, 1, 21, 30), Rect2(323, 1, 20, 30)]

func _ready() -> void:
	coins = FadeEffect.coins
	ones_place = get_child(3)
	tens_place = get_child(2)
	var ones_atlas: AtlasTexture = ones_place.texture
	var tens_atlas: AtlasTexture = tens_place.texture
	
	if coins < 10:
		tens_atlas.region = number_regions[int(str(0)[0])]
		ones_atlas.region = number_regions[int(str(coins)[0])]
	else:
		tens_atlas.region = number_regions[int(str(coins)[0])]
		ones_atlas.region = number_regions[int(str(coins)[1])]


func _on_player_coin_collected() -> void:
	coins += 1
	FadeEffect.coins = coins
	var ones_atlas: AtlasTexture = ones_place.texture
	var tens_atlas: AtlasTexture = tens_place.texture
	
	if coins < 10:
		ones_atlas.region = number_regions[int(str(coins)[0])]
	else:
		tens_atlas.region = number_regions[int(str(coins)[0])]
		ones_atlas.region = number_regions[int(str(coins)[1])]
