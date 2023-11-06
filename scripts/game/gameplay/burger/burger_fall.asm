.namespace BURGER {


	.label FALL_FRAMES = 1


	.label LAND_FRAME_2_TIME = 5
	.label LAND_FRAME_1_TIME = 2
	.label BOUNCE_FRAME_2_TIME = 11
	.label BOUNCE_FRAME_1_TIME = 1



	HandleFall: {

		lda LayerCharY, x
		cmp #24
		bne NotBottom

		lda PO4, x
		tay

		jmp SetComplete

	NotBottom:

		//inc FallSpeed, x
		lda FallSpeed, x
		and #%00000111
		bne NotDouble

		lda #0
		sta LayerTimer, x
		jmp Skipy


	NotDouble:
		//clc
		//adc #1
		lda #FALL_FRAMES
		sta LayerTimer, x

	Skipy:

		jsr GetLayerData

		lda PO4, x
		tay
		sta ChunkID

		lda #2
		sta PixelsMoved, x

		lda ChunkDepth, y
		sta TroddenAmount
		clc
		adc #1
		cmp #4
		bcc DepthOk

	NextChar:

		lda #0
		sta ChunkDepth, y
		sta Chunk1_Depth, x
		sta PrevDepth, x
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y
		sta ChunkDepth + 3, y
		sta ChunkTrodden + 1, y
		sta ChunkTrodden + 2, y
		sta ChunkTrodden + 3, y
		sta ChunkTrodden, y

		jsr RestoreMap

		ldx ZP.LayerID
		inc LayerCharY, x

		ldy #40
		lda (ZP.ScreenBackupAddress), y
		tay

		lda CHAR_COLORS, y
		and #CHAR_FLOOR
		beq NotLanded


		jmp LandedOnFloor

	NotLanded:
		
		jmp DrawBurger

	DepthOk:

		sta ChunkDepth, y
		sta Chunk1_Depth, x
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y
		sta ChunkDepth + 3, y



		lda TroddenAmount
		bne DrawNow


	CheckLandSolid:

		jsr FindBurgerKnocked
		bmi DrawNow

		pha

		txa
		ldx ZP.LayerID
		sta BumpBurger, x

		pla

		cmp #STATE_COMPLETE
		bne Knocked

		ldx ZP.LayerID

		lda AboutToComplete, x
		bne SetComplete

		inc AboutToComplete, x	

	Knocked:

		jsr BounceOffBurger

	DrawNow:

		jmp DrawBurger



	}

	SetComplete: {

		
		lda #SCORE.BURGER_FALL
		jsr SCORE.AddScoreType

		lda #STATE_COMPLETE
		sta LayerState, x

		dec TotalLayers
		bne StillToGo

		jsr PETER.SetWin

	StillToGo:

		lda #0
		sta LayerTimer, x

		lda #1
		sta PixelsMoved, x

		lda #0
		sta ChunkDepth + 1, y
		sta Chunk1_Depth, x
		sta ChunkDepth + 2, y
		sta ChunkDepth, y
		sta ChunkDepth + 3, y

		jsr CheckFallScore

		jmp DrawBurger


		rts
	}

	
	BounceOffBurger: {

		sfx(SFX_BOUNCE)

		ldx ZP.LayerID
	
		lda LayerSmash, x
		beq NoQueueSmash

		dec LayerSmash, x

		lda #1
		sta WillSmash, x


	NoQueueSmash:
		
		dec LayerCharY, x

		lda #-5
		sta PixelsMoved, x

		ldy ChunkID
		
		lda #0
		sta AboutToBounce, x
		
		lda #2
		sta ChunkDepth + 0, y
		sta Chunk1_Depth, x
		sta ChunkDepth + 3, y

		lda #3
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y

		lda #BOUNCE_FRAME_1_TIME
		clc
		adc LayerTimer, x
		sta LayerTimer,x

		lda #STATE_BOUNCE_1
		sta LayerState, x


		rts
	}


	BounceBurger: {

		lda PO4, x
		tay

		lda #STATE_BOUNCE_2
		sta LayerState, x

		lda #BOUNCE_FRAME_2_TIME
		sta LayerTimer, x

		lda LayerSmash, x
		beq NoSmash

		lda LayerTimer, x
		clc
		adc #10
		sta LayerTimer, x


	NoSmash:

		lda #1
		//sta PixelsMoved, x

		lda #1
		sta ChunkDepth, y
		sta Chunk1_Depth, x
		sta ChunkDepth + 3, y

		lda #0
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y

		jsr GetLayerData
		jsr RestoreMap

		ldx ZP.LayerID

		jmp DrawBurger


	}


	RestartFall: {

		

		lda BumpBurger, x
		bmi NoBump

		tay

		lda LayerState, y
		cmp #STATE_STILL
		beq NoBump

		cmp #STATE_FALLING
		beq NoBump

		cmp #STATE_COMPLETE
		beq NoBump

		//lda LayerTimer, y
		//cmp/ #2
		//bcc NoBump

		rts



	NoBump:

		lda #255
		sta BumpBurger, x

		lda PO4, x
		tay

		lda #STATE_FALLING
		sta LayerState, x

		lda #0
		sta LayerTimer, x

		lda #1
		sta PixelsMoved, x

		lda #0
		sta Chunk1_Depth, x
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y
		sta ChunkDepth, y
		sta ChunkDepth + 3, y

		jsr GetLayerData
		jsr RestoreMap

		ldx ZP.LayerID

	


		jmp DrawBurger


	}




	FindBurgerKnocked: {


		ldx ZP.LayerID
		lda LayerCharY, x
		clc
		adc #1
		sta ZP.Temp3

		lda LayerCharX, x
		sta ZP.Temp4


		ldx #0

		Loop:

			lda LayerState, x
			bpl Okay

			jmp Done

		Okay:

			cmp #STATE_FALLING
			beq EndLoop

			cmp #STATE_STILL
			beq Knock

			//jmp Knock
			cmp #STATE_COMPLETE
			beq Knock

			//cmp #STATE_FALLING
			//beq Knock

			cmp #STATE_LANDING
			beq Knock

			cmp #STATE_LANDING_2
			beq Knock

			jmp EndLoop

		Knock:

			lda LayerCharX, x
			cmp ZP.Temp4
			bne EndLoop

			lda LayerCharY, x
			cmp ZP.Temp3
			bne EndLoop
		
		GotBurger:

			jsr MakeBurgerFall

			lda LayerState, x
			rts

		EndLoop:

			inx
			cpx #MAX_LAYERS
			beq Done

			jmp Loop



		Done:

		lda #255

		rts
	}



	LandedOnFloor: {

		sfx(SFX_BOUNCE)


		ldx ZP.LayerID


	CheckComplete:

		lda AboutToComplete, x
		beq NotAboutComplete

		jmp SetComplete

	NotAboutComplete:

		lda CHAR_COLORS, y
		and #%10000000
		beq NotComplete

		lda #1
		sta AboutToComplete, x

		lda #0
		sta LayerSmash, x

		jsr BounceOffBurger
		jmp DrawBurger


	NotComplete:

		lda LayerSmash, x
		beq NoQueueSmash

		dec LayerSmash, x

		lda #1
		sta WillSmash, x

	NoQueueSmash:
		
		lda #STATE_LANDING
		sta LayerState, x

		lda #LAND_FRAME_1_TIME
		sta LayerTimer, x

		ldy ChunkID

		lda #-1
		sta PixelsMoved, x

		lda #2
		sta Chunk1_Depth, x
		sta ChunkDepth, y
		sta ChunkDepth + 3, y

		lda #3
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y


		jmp DrawBurger

	}


	BounceFloor: {



		lda PO4, x
		tay
	
		lda #STATE_LANDING_2
		sta LayerState, x

		lda #LAND_FRAME_2_TIME
		sta LayerTimer, x

		lda #1
		sta PixelsMoved, x

		lda #1
		sta ChunkDepth, y
		sta Chunk1_Depth, x
		sta ChunkDepth + 3, y

		lda #0
		sta ChunkDepth + 1, y
		sta ChunkDepth + 2, y

		jsr GetLayerData
		jsr RestoreMap

		ldx ZP.LayerID


		jmp DrawBurger



	}

	StopBouncing: {

		ldx ZP.LayerID


		lda #SCORE.BURGER_FALL
		jsr SCORE.AddScoreType
			

		lda WillSmash, x
		beq NoSmash

		lda #0
		sta WillSmash, x

		lda #STATE_FALLING
		sta LayerState, x

		jmp DrawBurger

	NoSmash:

		lda PO4, x
		tay

		lda #STATE_STILL
		sta LayerState, x

		lda #0
		sta LayerTimer, x
//
		//lda #1
		//sta PixelsMoved, x

		lda #0
		sta ChunkDepth + 1, y
		sta Chunk1_Depth, x
		sta ChunkDepth + 2, y
		sta ChunkDepth, y
		sta ChunkDepth + 3, y

		jsr GetLayerData
		jsr RestoreMap

		ldx ZP.LayerID

		jsr CheckFallScore

		jmp DrawBurger




		rts
	}

}