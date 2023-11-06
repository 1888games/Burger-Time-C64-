.namespace BURGER {

	.label LEVEL_1_LAYERS = 16
	.label LEVEL_2_LAYERS = 16
	.label LEVEL_3_LAYERS = 18
	.label LEVEL_4_LAYERS = 32
	.label LEVEL_5_LAYERS = 16
	.label LEVEL_6_LAYERS = 18


	LayersPerLevel:	.byte LEVEL_1_LAYERS, LEVEL_2_LAYERS, LEVEL_3_LAYERS, LEVEL_4_LAYERS, LEVEL_5_LAYERS, LEVEL_6_LAYERS

	LayerStart:		.byte 00, 16, 32, 50, 82, 98
	LayerEnd:		.byte 15, 31, 49, 81, 97, 115


	LayerColours:	.byte YELLOW + 8, GREEN + 8, YELLOW + 8, RED + 8, RED + 8, YELLOW + 8

	
	TroddenOffsets:	.byte 0, 16, 48, 80



	
	LayerTypeData:	.byte BUN_TOP, BUN_TOP, BUN_TOP, BUN_TOP
					.byte LETTUCE, LETTUCE, LETTUCE, LETTUCE
					.byte PATTY, PATTY, PATTY, PATTY
					.byte BUN_BASE, BUN_BASE, BUN_BASE, BUN_BASE

					.byte BUN_TOP, BUN_TOP, BUN_TOP, BUN_TOP
					.byte LETTUCE, CHEESE, CHEESE, LETTUCE
					.byte CHEESE, LETTUCE, LETTUCE, CHEESE
					.byte BUN_BASE, BUN_BASE, BUN_BASE, BUN_BASE

					.byte BUN_TOP, BUN_TOP, BUN_TOP, BUN_TOP
					.byte PATTY, TOMATO, PATTY, TOMATO
					.byte BUN_BASE, BUN_BASE, BUN_BASE, BUN_BASE

					.byte BUN_TOP, BUN_TOP
					.byte TOMATO, PATTY
					.byte BUN_BASE, BUN_BASE

					.byte BUN_TOP, BUN_TOP, BUN_TOP, BUN_TOP
					.byte CHEESE, LETTUCE, TOMATO, CHEESE
					.byte TOMATO, TOMATO, LETTUCE, LETTUCE
					.byte LETTUCE, PATTY, TOMATO, PATTY
					.byte PATTY, TOMATO, PATTY, TOMATO
					.byte LETTUCE, CHEESE, CHEESE, LETTUCE
					.byte TOMATO, LETTUCE, LETTUCE, TOMATO
					.byte BUN_BASE, BUN_BASE, BUN_BASE, BUN_BASE

					.byte BUN_TOP, BUN_TOP
					.byte TOMATO, TOMATO
					.byte LETTUCE, PATTY
					.byte PATTY, LETTUCE
					.byte LETTUCE, PATTY
					.byte PATTY, TOMATO
					.byte TOMATO, LETTUCE
					.byte BUN_BASE, BUN_BASE

					.byte BUN_TOP, BUN_TOP, BUN_TOP, BUN_TOP
					.byte CHEESE, CHEESE, CHEESE, PATTY
					.byte PATTY, PATTY, CHEESE, CHEESE
					.byte BUN_BASE, CHEESE, PATTY, BUN_BASE
					.byte BUN_BASE, BUN_BASE




	LayerColumn:	.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3

					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3

					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3

					.byte 0, 3
					.byte 0, 3
					.byte 0, 3

					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3

					.byte 1, 2
					.byte 1, 2
					.byte 1, 2
					.byte 1, 2
					.byte 1, 2
					.byte 1, 2
					.byte 1, 2
					.byte 1, 2

					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 0, 1, 2, 3
					.byte 1, 2




	LayerRow:		.byte 2, 0, 0, 0
					.byte 4, 5, 2, 2
					.byte 7, 7, 5, 4
					.byte 9, 9, 9, 6


					.byte 0, 0, 0, 0
					.byte 1, 1, 5, 2
					.byte 2, 3, 7, 3
					.byte 4, 8, 8, 4

					.byte 0, 0, 0, 0
					.byte 2, 1, 1, 2
					.byte 3, 3, 3, 3


					.byte 7, 7
					.byte 8, 8
					.byte 9, 9

					.fill 4, 0
					.fill 4, 1
					.fill 4, 2
					.fill 4, 3
					.fill 4, 4
					.fill 4, 5
					.fill 4, 6
					.fill 4, 7

					.fill 2, 0
					.fill 2, 1
					.fill 2, 2
					.fill 2, 3
					.fill 2, 4
					.fill 2, 5
					.fill 2, 6
					.fill 2, 7

					.byte 1, 0, 1, 0
					.byte 3, 2, 3, 2
					.byte 5, 4, 5, 4
					.byte 9, 6, 9, 6
					.byte 8, 6





}