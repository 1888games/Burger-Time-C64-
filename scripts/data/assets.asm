

 	* = $c400 "Sprites" //Start at frame #16
 	.import binary "../assets/sprites/burger - sprites.bin"

//* = $2000 "SFX"

//SFX:	.import binary "../assets/sfx2.prg"   
		

* = $f000 "Charset"

CHAR_SET:	.import binary "../assets/charsets/burger - Chars.bin"   

* = $b000 "Map Data" 

* = * "Game Tiles" 
MAP_TILES: .import binary "../assets/charsets/burger - Tiles.bin"

* = * "Game Colours" 
CHAR_COLORS: .import binary "../assets/charsets/burger - CharAttribs_L1.bin"

	
* = * "Map 0" 
MAP_0: 		.import binary "../assets/charsets/burger - (8bpc, 20x13) [00,00] SubMap.bin"

* = * "Map 1" 
MAP_1: 		.import binary "../assets/charsets/burger - (8bpc, 20x13) [01,00] SubMap.bin"


* = * "Map 2" 
MAP_2: 		.import binary "../assets/charsets/burger - (8bpc, 20x13) [02,00] SubMap.bin"


* = * "Map 3" 
MAP_3: 		.import binary "../assets/charsets/burger - (8bpc, 20x13) [03,00] SubMap.bin"


* = * "Map 4" 
MAP_4: 		.import binary "../assets/charsets/burger - (8bpc, 20x13) [04,00] SubMap.bin"


* = * "Map 5" 
MAP_5: 		.import binary "../assets/charsets/burger - (8bpc, 20x13) [05,00] SubMap.bin"



* = $b900 "Bonus Chars"

BONUS_CHARS:	.import binary "../assets/charsets/bonus - Chars.bin"   






* = $e800 "Title Charset"

TITLE_SET:	.import binary "../assets/charsets/burger_non_game - Chars.bin"   

* = $9000 "Title Map Data" 

* = * "Title Tiles" 
TITLE_TILES: .import binary "../assets/charsets/burger_non_game - Tiles.bin"

* = * "Title Colours" 
TITLE_COLORS: .import binary "../assets/charsets/burger_non_game - CharAttribs_L1.bin"


	
* = * "Cast" 
MAP_CAST: 		.import binary "../assets/charsets/burger_non_game - (8bpc, 20x13) [00,00] SubMap.bin"

* = * "Table" 
MAP_TABLE: 		.import binary "../assets/charsets/burger_non_game - (8bpc, 20x13) [01,00] SubMap.bin"


* = * "Scoring" 
MAP_SCORING: 	.import binary "../assets/charsets/burger_non_game - (8bpc, 20x13) [02,00] SubMap.bin"


* = * "Game Ready" 
MAP_READY: 		.import binary "../assets/charsets/burger_non_game - (8bpc, 20x13) [03,00] SubMap.bin"

* = * "Deco" 
MAP_DECO: 		.import binary "../assets/charsets/burger_non_game - (8bpc, 20x13) [04,00] SubMap.bin"

* = * "Enter Name" 
MAP_NAME: 		.import binary "../assets/charsets/burger_non_game - (8bpc, 20x13) [05,00] SubMap.bin"



// = * "Title Map" 
//TITLE_MAP: 		.import binary "../assets/title - MapArea (8bpc, 20x13).bin"


	.pc = sid.location "sid"
	.fill sid.size, sid.getData(i)
