extends TileMap

var noise : OpenSimplexNoise = OpenSimplexNoise.new() #Terrain Noise Variable
var cave_noise : OpenSimplexNoise = OpenSimplexNoise.new() #Cave Noise Variable
var x_length : int = 2048 #World Length
var y_depth : int = 128 #World Depth
var height : int = 64 #World Height

func create_tree(x,y,length,new):
	if new:
		for i in length:
			if get_cell(x,y-i) != -1:
				length = 0

	if length > 0:
		if new: set_cell(x,y,TRUNK_BASE) #TRUNK_BASE
		elif length == 1: set_cell(x,y,LEAVES) #LEAVES
		else: set_cell(x,y,TRUNK)#TRUNK
		create_tree(x,y-1, length-1,false)
	
		
enum {
	DIRT = 0,
	GRASS = 1,
	STONE = 2,
	TRUNK_BASE = 3,
	TRUNK = 4,
	LEAVES = 5,
	IRON = 6,
	TNT = 7,
	TNT_ACTIVATED_1 = 8,
	TNT_ACTIVATED_2 = 9,
	STONE_BG = 10,
	SAPPLING = 11,
	BREAKBLOCK1 = 12,
	BREAKBLOCK2 = 13,
	BREAKBLOCK3 = 14,
	BREAKBLOCK4 = 15,
	BREAKBLOCK5 = 16,
	BREAKBLOCK6 = 17,
	BREAKBLOCK7 = 18,
}

var selected_block = GRASS

onready var selector : Sprite = $selector
onready var tilemap = $TileMap

func _physics_process(_delta: float) -> void:
	
	if(Input.is_action_just_pressed("1")):
		selected_block = GRASS
	if(Input.is_action_just_pressed("2")):
		selected_block = STONE
	if(Input.is_action_just_pressed("3")):
		selected_block = DIRT
	if(Input.is_action_just_pressed("4")):
		selected_block = TNT
	if(Input.is_action_just_pressed("5")):
		selected_block = TRUNK
	if(Input.is_action_just_pressed("6")):
		selected_block = LEAVES
	if(Input.is_action_just_pressed("7")):
		selected_block = IRON
	if(Input.is_action_just_pressed("8")):
		selected_block = SAPPLING
	if(Input.is_action_just_pressed("9")):
		selected_block = GRASS
	
	if(Input.is_action_just_pressed("b")):
		if selector.visible == true:
			selector.visible = false
		else:
			selector.visible = true

	if(Input.is_action_pressed("mb_right")):
		if selector.visible == true:
			var tile : Vector2 = world_to_map(selector.mouse_pos * 16) # gets the tile we clicked on
			var block = get_cell(tile.x,tile.y)
			if block == -1:
				if selected_block == SAPPLING:
					if get_cell(tile.x, tile.y+1) == GRASS:
						create_tree(tile.x,tile.y,randi()%4 + 4, true)
				else:
					set_cellv(tile,selected_block)
				
			if block == TRUNK:
				if get_cell(tile.x, tile.y+1) == GRASS:
					set_cell(tile.x, tile.y, TRUNK_BASE)
	
	if(Input.is_action_pressed("mb_left")):
		if selector.visible == true:
			var tile : Vector2 = world_to_map(selector.mouse_pos * 16)
			var block = get_cell(tile.x, tile.y)
			
			if block == GRASS: # If grass has tree attached, Remove tree. #
				if get_cell(tile.x, tile.y-1) == TRUNK_BASE:
					break_tree(tile.x, tile.y)
					
			if block == TNT: # Activate TNT when left clicked.
				activate_tnt(tile.x, tile.y)
				
			if  block == TRUNK or block == TRUNK_BASE:
				break_tree(tile.x, tile.y)
				
			var tilemap = $TileMap

			var mouse :Vector2 = get_global_mouse_position()
			var cell :Vector2 = tilemap.world_to_map(mouse)
			var abc :int = tilemap.get_cellv(cell)
			var new_abc :int = (abc + 1) % 3 # just an example plus 1 modules 3
			tilemap.set_cellv(cell, new_abc)
				
			#set_cellv(tile,-1)

func _ready():
	randomize() #Randomize the internal game seed

	#Set the seed as random numbers
	noise.seed = randi()
	cave_noise.seed = randi()

	noise.period = 300 #The farther away from zero the smoother the terrain is going to look

	for x in range(-x_length,x_length): #Loop through the X length starting from negative to positive
		var y = ceil(noise.get_noise_2d(x,0) * height) #Get the noise at the given length and multiply it by the height then round it
		self.set_cellv(Vector2(x,y),GRASS) #Set the cell at the given X and Y GRASS
		if randi()%15 == 4 and get_cell(x,y-1) == -1:
			create_tree(x,y-1,randi()%4 + 4, true)

		for depth in range(y+5,y_depth): #Generate stone 5 blocks down from the given Y value
			self.set_cellv(Vector2(x,depth),STONE)

		for depth in range(y,y+5): #Fill in air gaps with dirt starting from the Y value to 5 blocks down
			if self.get_cellv(Vector2(x,depth)) == TileMap.INVALID_CELL: #'Air Blocks' are empty cells
				self.set_cellv(Vector2(x,depth),DIRT)
				if randi()%15 == 4:
					set_cell(x, y+randi()%15+5,IRON)

		for depth in range(y,y_depth): #Start from the Y and go down to the Y depth
			var yy = noise.get_noise_2d(x,depth) #Get 2d noise from the given X and Y value

			if abs(yy) < .03: #Check if the absolute value of the noise is less than .03
				self.set_cellv(Vector2(x,depth + y),-1) #Remove the block at the given X and Y value
				if get_cell(x, y-1) == TRUNK_BASE or get_cell(x, y-1) == TRUNK:
					if get_cell(x, y) != GRASS:
						break_tree(x,y)
				
			
			
func break_tree(x, y):
	var i = 0
	while i < 200:
		i+=1
		var block = get_cell(x, y-i)
		if block == TRUNK or block == LEAVES or block == TRUNK_BASE:
			# Drop Removed Block Item #
			yield(get_tree().create_timer(0.1), "timeout")
			set_cell(x, y-i, -1)

			
func destroyRadius(x,y,r):

	var selectedX = -r
	var selectedY = -r
	
	var variableX = x + selectedX
	var variableY = y + selectedY
	
	var exploding = true
	
	while exploding == true:
		var BlockOver = get_cell(variableX, variableY-1)
		if get_cell(variableX, variableY) != TNT: # If another TNT is within the radius of explotion, It will also activate.
			set_cell(variableX, variableY, -1)
			if BlockOver == TRUNK or BlockOver == TRUNK_BASE:
				break_tree(variableX, variableY+1)
		else:
			activate_tnt(variableX, variableY)
			
		if selectedY >= r and selectedX >= r:
			exploding = false
		
		selectedX += 1
		
		if selectedX >= r+1:
			selectedX = -r
			selectedY += 1
			
		# Set Next Values #
		variableX = x + selectedX
		variableY = y + selectedY

func activate_tnt(x, y):
	var i = 0
	var selectedImage = TNT_ACTIVATED_1
	while i < 7:
		i+=1
		yield(get_tree().create_timer(0.1), "timeout")
		if selectedImage == TNT_ACTIVATED_1:
			selectedImage = TNT_ACTIVATED_2
		else:
			selectedImage = TNT_ACTIVATED_1
		set_cell(x,y,selectedImage)
	
	var explotionRadius = randi()%4
	
	if explotionRadius == 0:
		explotionRadius = 1
	
	destroyRadius(x,y,explotionRadius)
