
.label ZERO= 					0
.label FALSE = 					0	
.label ALL_ON = 				255
.label TRUE = 					1


.label PAL = 					0
.label NTSC =	 				1

.label GAME_MAP =				0
.label GAME_TITLE = 1


.label PROCESSOR_PORT = 		$01
.label INTERRUPT_VECTOR = 		$fffe
.label JOY_PORT_2 = 			$dc00

.label SCREEN_RAM = 			$c000
.label SPRITE_POINTERS = SCREEN_RAM + $3f8


.label IRQControlRegister1 = 	$dc0d
.label IRQControlRegister2 = 	$dd0d


.label WHITE_MULT = 9
.label RED_MULT = 10
.label CYAN_MULT = 11
.label PURPLE_MULT = 12
.label GREEN_MULT = 13
.label BLUE_MULT = 14
.label YELLOW_MULT = 15

.label LEFT_MASK = 1
.label RIGHT_MASK = 2
.label DOWN_MASK = 4
.label UP_MASK= 8



.label LEFT_LADDER_FOOT = 10
.label RIGHT_LADDER_FOOT = 11
.label LEFT_LADDER = 12
.label RIGHT_LADDER = 14
.label LEFT_LADDER_FOOT_2 = 19
.label RIGHT_LADDER_FOOT_2 = 20

.label CHAR_FLOOR = 16
.label CHAR_LADDER = 32



.label BUN_TOP = 0
.label LETTUCE = 1
.label CHEESE = 2
.label TOMATO = 3
.label PATTY = 4
.label BUN_BASE = 5

.label NUM_CHAR = 26

.label PETER_SPRITE = 6

.label SCREEN_BACKUP = $F800
.label COLOUR_BACKUP = $FC00

.label NIL = 0
.label ONE = 1


.label GAME_MODE_TITLE = 0
.label GAME_MODE_DEAD = 1
.label GAME_MODE_PLAY = 2
.label GAME_MODE_OVER = 3



.label SFX_CHANNEL_1 = 680
.label SFX_CHANNEL_2 = 681





.label MUSIC_MAIN = 0
.label MUSIC_COMPLETE = 3
.label MUSIC_SILENT = 2
.label MUSIC_START = 1
.label MUSIC_DEAD = 4





