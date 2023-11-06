.namespace POPUP {


	.label FirstSprite = 89

	Timer:		.byte 255
	Pointer:	.byte 255
	X:			.byte 0
	Y:			.byte 0


	Show: {	

		pha

		lda PETER.PepperThrown
		bne Exit

		pla
		// y = sprite ID
		clc
		adc #FirstSprite
		sta Pointer


		lda SCORE.ScoreX, x
		sta X

		lda SCORE.ScoreY, x
		sta Y

		lda #50
		sta Timer
		rts


	Exit:

		pla
		rts
	}




	FrameUpdate: {



		CheckTimer:

			lda Timer
			bmi Finish
			beq Ready


			lda Pointer
			sta SPRITE_POINTERS + 7

			lda X
			sta VIC.SPRITE_7_X

			lda Y
			sec
			sbc #20
			sta VIC.SPRITE_7_Y

			lda #WHITE
			sta VIC.SPRITE_COLOR_7

			dec Timer
			rts

		Ready:

			lda PETER.PepperThrown
			bne DontMessSprite

			lda #0
			sta VIC.SPRITE_7_Y
			sta VIC.SPRITE_7_X

		DontMessSprite:

			dec Timer

		Finish:

			rts


	}




}