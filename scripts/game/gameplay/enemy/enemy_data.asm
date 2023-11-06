.namespace ENEMY {


	EnemiesPerLevel:	.byte 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6

	DataStart:			.byte 0, 4, 8, 14, 20, 26, 32, 38, 44, 50, 56, 62



	SpawnRow:			.byte 18, 18, 00, 00
						.byte 08, 08, 00, 00
						.byte 14, 18, 00, 00, 14, 18
						.byte 14, 14, 00, 00, 14, 14
						.byte 22, 22, 00, 00, 22, 22
						.byte 16, 14, 12, 02, 16, 14
						.byte 18, 18, 00, 00, 18, 18
						.byte 08, 08, 00, 00, 08, 08
						.byte 14, 18, 00, 00, 14, 18
						.byte 14, 14, 00, 00, 14, 14
						.byte 22, 22, 00, 00, 22, 22
						.byte 16, 14, 12, 02, 16, 14


	SpawnType:			.byte EGG, SAUSAGE, SAUSAGE, SAUSAGE
						.byte EGG, SAUSAGE, SAUSAGE, SAUSAGE
						.byte PICKLE, EGG, SAUSAGE, PICKLE, SAUSAGE, PICKLE
						.byte PICKLE, SAUSAGE, PICKLE, SAUSAGE, SAUSAGE, SAUSAGE
						.byte PICKLE, EGG, PICKLE, EGG, EGG, EGG
						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE

						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE
						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE
						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE
						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE
						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE
						.byte PICKLE, EGG, SAUSAGE, PICKLE, EGG, SAUSAGE






	SpawnDelay:			.byte 000, 040, 111, 200
						.byte 000, 034, 113, 201
						.byte 000, 030, 060, 090, 146, 176
						.byte 000, 060, 085, 130, 200, 255
						.byte 000, 030, 085, 115, 195, 255
						.byte 000, 030, 060, 090, 120, 150

						.byte 000, 030, 060, 090, 120, 150
						.byte 000, 030, 060, 090, 120, 150
						.byte 000, 030, 060, 090, 120, 150
						.byte 000, 030, 060, 090, 120, 150
						.byte 000, 030, 060, 090, 120, 150
						.byte 000, 030, 060, 090, 120, 150



	SpawnSide:			.byte RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT

						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT
						.byte RIGHT, LEFT, RIGHT, LEFT, RIGHT, LEFT



}