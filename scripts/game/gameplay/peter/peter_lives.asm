.namespace PETER {



	LivesRemaining:		.byte 3

	.label CHAR_HAT = 255
	.label CHAR_FACE = 25



	SetupLives: {

		lda #2
		sta LivesRemaining


		rts
	}


	DrawLives: {

		ldx #30
		ldy #20



		jsr PLOT.GetCharacter

		ldx #0
		ldy #0

		Loop:	

			stx ZP.X

			cpx LivesRemaining
			beq StopDrawing


			lda #CHAR_HAT
			sta (ZP.ScreenAddress), y

			lda #WHITE
			sta (ZP.ColourAddress), y

			sty ZP.Amount
			tya
			clc
			adc #40
			tay

			lda #CHAR_FACE
			sta (ZP.ScreenAddress), y

			lda #YELLOW
			sta (ZP.ColourAddress), y

			ldy ZP.Amount
			iny
			cpy #7
			bcc EndLoop

			ldy #0

			ldx ZP.X
			cpx #14
			bcs StopDrawing

			jsr UTILITY.MoveDownRow
			jsr UTILITY.MoveDownRow

		EndLoop:

			ldx ZP.X
			inx
			jmp Loop

		StopDrawing:




		rts
	}


	IncreaseLives: {

		sfx(SFX_EXTRA)

		inc LivesRemaining

		jmp DrawLives

	}

	DecreaseLives: {
		
		dec LivesRemaining
		bpl NotGameOver

		lda #0
		sta LivesRemaining

		sei
		ldx #$FF
		txs

		jmp GAME_OVER.Show

	NotGameOver:

		sei
		ldx #$FF
		txs
		
		jmp READY.Show 



	}


}