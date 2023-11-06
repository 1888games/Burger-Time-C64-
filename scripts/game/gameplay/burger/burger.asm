.namespace BURGER {

	* = * "Burger"

	.label NO_LAYER = 255
	.label SPRITE_X_START = 52
	.label SPRITE_X_GAP = 48
	.label SPRITE_Y_START = 58
	.label SPRITE_Y_GAP = 16

	.label STATE_STILL = 0
	.label STATE_FALLING = 1
	.label STATE_LANDING = 2
	.label STATE_LANDING_2 = 3
	.label STATE_BOUNCE_1 = 4
	.label STATE_BOUNCE_2 = 5
	.label STATE_COMPLETE = 6

	.label BURGER_CHAR_START = 46

	#import "game/gameplay/burger/burger_data.asm"
	#import "game/gameplay/burger/burger_draw.asm"
	#import "game/gameplay/burger/burger_fall.asm"
	#import "game/gameplay/burger/burger_tread.asm"
	#import "game/gameplay/burger/burger_whack.asm"

	LayerType:			.fill MAX_LAYERS, NO_LAYER
	ChunkDepth:			.fill MAX_LAYERS * 4, 0
	ChunkTrodden:		.fill MAX_LAYERS * 4, 0
	Chunk1_Depth:		.fill MAX_LAYERS, 0

	PrevDepth:			.fill MAX_LAYERS, 0
	PrevCharX:			.fill MAX_LAYERS, 0
	PrevCharY:			.fill MAX_LAYERS, 0
	LayerCharX:			.fill MAX_LAYERS, 0
	LayerCharY:			.fill MAX_LAYERS, 0
	BaseColour:			.fill MAX_LAYERS, 0

	LayerTimer:			.fill MAX_LAYERS, 0
	AboutToBounce:		.fill MAX_LAYERS, 0
	AboutToComplete:	.fill MAX_LAYERS, 0
	LayerSmash:			.fill MAX_LAYERS, 0
	WillSmash:			.fill MAX_LAYERS, 0
	FallSpeed:			.fill MAX_LAYERS, 0
	PixelsMoved:		.fill MAX_LAYERS, 0
	EnemiesDropped:		.fill MAX_LAYERS, 0
	EnemyDroppedID:		.fill MAX_LAYERS, 0


	* = * "Bump Burger"
	BumpBurger:			.fill MAX_LAYERS, 0
	LayerState:			.fill MAX_LAYERS, NO_LAYER

	ColourRamAddresses_LSB:	.fill MAX_LAYERS, 0
	ColourRamAddresses_MSB:	.fill MAX_LAYERS, 0

	CharColumnX:		.fill 4, 3 + (i * 6)
	CharRowY:			.fill 10, 1 + (i * 2)
	PO4:				.fill 32, i * 4

	ChunkDataOffset:	.byte 0
	ScreenOffset:		.byte 0
	ChunkID:			.byte 0
	TroddenAmount:		.byte 0
	ChunkTypeID:		.byte 0
	StillChunkIDS:		.byte 0
	TotalLayers:		.byte 0

	

	ChunkUnderFoot:		.byte 0
	TreadStartX:		.byte 0
	TreadStartY:		.byte 0

				// y = 
	

	SetupLevel: {

		ldx GAME.MapLevel

		lda LayerStart, x
		sta ZP.CurrentID

		lda LayersPerLevel, x
		sta ZP.EndID

		ldx #0
		stx TotalLayers

		Loop:	

				inc TotalLayers

				stx ZP.LayerID
				ldy ZP.CurrentID

			GetLayerType:

				lda LayerTypeData, y

				sta LayerType, x
				tay

				

			GetAddresses:	

				lda LayerColours, y
				sta BaseColour, x

				lda #0
				sta LayerTimer, x
				sta LayerState, x
				sta AboutToBounce, x
				sta AboutToComplete, x
				sta LayerSmash, x
				sta WillSmash, x

				lda #255
				sta BumpBurger, x
		
			

			GetLayerColumn:

				ldy ZP.CurrentID
				ldx ZP.LayerID

				lda LayerColumn, y
				tay

				lda CharColumnX, y
				sta LayerCharX, x
				sta ZP.Amount

			GetLayerRow:

				ldy ZP.CurrentID

				lda LayerRow, y
				tay

				lda CharRowY, y
				sta LayerCharY, x
				sta PrevCharY, x
				tay

				ldx ZP.Amount


				jsr PLOT.GetCharacter

				ldx ZP.LayerID

				lda ZP.ScreenAddress
				sta ScreenAddresses_LSB, x

				lda ZP.ScreenAddress + 1
				sta ScreenAddresses_MSB, x

				lda ZP.ColourAddress
				sta ColourRamAddresses_LSB, x

				lda ZP.ColourAddress + 1
				sta ColourRamAddresses_MSB, x
				//lda ()
			

			LevelChunks:

				ldx ZP.LayerID

				lda PO4, x
				tay

				lda #0
				sta ChunkDepth, y
				sta ChunkDepth + 1, y
				sta ChunkDepth + 2, y
				sta ChunkDepth + 3, y
				sta Chunk1_Depth, x
				sta PrevDepth, x

				sta ChunkTrodden, y
				sta ChunkTrodden + 1, y
				sta ChunkTrodden + 2, y
				sta ChunkTrodden + 3, y



			SpriteData:

				jsr DrawBurger
				//jsr CopySpriteData

			EndLoop:	

				inc ZP.CurrentID
				ldx ZP.LayerID
				inx
				cpx ZP.EndID
				beq Done
				jmp Loop

		Done:
		
			cpx #MAX_LAYERS
			beq Finish

		Loop2:

			lda #NO_LAYER
			sta LayerState, x

			inx
			cpx #MAX_LAYERS
			bcc Loop2


		Finish:

		rts
	}


	ReloadLevel: {


		ldx #0

		Loop:

			stx ZP.LayerID

			lda LayerState, x
			bmi Done

			jsr DrawBurger

		EndLoop:

			ldx ZP.LayerID
			inx
			cpx #MAX_LAYERS
			bcc Loop

		Done:
		
			rts




	}

	CheckFallScore: {

		lda EnemiesDropped, x
		beq Exit
		tay

		clc
		adc #6

		pha

		lda EnemyDroppedID, x
		tax

		pla

		jsr SCORE.AddScoreType

		ldx ZP.LayerID

		Exit:

		rts
	}

	FrameUpdate: {	

		ldx #0

		lda GAME.LevelComplete
		beq Loop

		rts

		Loop:

			stx ZP.LayerID

			lda LayerState, x
			bmi Done

			lda #0
			sta PixelsMoved, x

			// lda LayerCharY, x
			// sta PrevCharY, x

			// lda Chunk1_Depth, x
			// sta PrevDepth, x

			lda LayerTimer, x
			beq Ready

			dec LayerTimer, x
			jmp EndLoop

		Ready:

			

			lda LayerState,x
			cmp #STATE_FALLING
			bcc EndLoop
			bne NotFalling

			jsr HandleFall

		NotFalling:

			cmp #STATE_LANDING
			bne NotLanding

			jsr BounceFloor

		NotLanding:

			cmp #STATE_LANDING_2
			bne NotLanding2

			jsr StopBouncing

		NotLanding2:

			cmp #STATE_BOUNCE_1
			bne NotBounce1

			jsr BounceBurger

		NotBounce1:

			cmp #STATE_BOUNCE_2
			bne NotBounce2

			jsr RestartFall


		NotBounce2:

			
		EndLoop:

			ldx ZP.LayerID
			inx
			cpx #MAX_LAYERS
			bcc Loop

		Done:
		
		rts
	}

	






}