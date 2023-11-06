SCORE:{

	* = * "Score"
	
	Value: 	.byte $00, $00, $00, $00	// H M L
	Best: 	.byte $0, $80, $02, 0

	.label CharacterSetStart = 26

	.label BURGER_FALL = 0

	ScoreH:		.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
	ScoreM:		.byte $00, $01, $03, $02, $05, $10, $15, $05, $10, $20, $40, $80, $60
	ScoreL:		.byte $50, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	ShowPopup:	.byte $FF, $FF, $FF, $FF, $03, $06, $07, $03, $06, $08, $0A, $0B, $0C


	ScoreQueue:	.fill 16, 255
	ScoreX:		.fill 16, 255
	ScoreY:		.fill 16, 255
	ScoreSprite: .fill 16, 255

	ScoresToProcess:	.byte 0


	Reset:{

		lda #0
		sta Value
		sta Value + 1
		sta Value + 2
		sta Value + 3
		sta ScoresToProcess

		//lda #$50
		//sta Value + 1



		ldx #0
		lda #255

		Loop:

			sta ScoreQueue, x

			inx
			cpx #16
			bcc Loop

		Finish:

		rts

	}


	Draw: {

		jsr DrawP1
		jsr DrawBest

		rts
	}


	AddScoreType: {

		stx ZP.X_Backup

		
		pha

		lda WALKERS.PosX, x
		sta ZP.Temp4

		lda WALKERS.PosY, x
		sta ZP.Temp3

		stx ZP.Temp2


		ldx #0

		Loop:

			lda ScoreQueue, x
			bmi Found

			inx
			cpx #16
			bcc Loop

		Found:

			pla
			sta ScoreQueue, x


			lda ZP.Temp4
			sta ScoreX, x

			lda ZP.Temp3
			sta ScoreY, x

			lda ZP.Temp2
			sta ScoreSprite, x

			inc ScoresToProcess

			ldx ZP.X_Backup

	

		rts
	}



	FrameUpdate: {


		lda ScoresToProcess
		beq Finish


		ldx #0

		Loop:

			stx ZP.X

			lda ScoreQueue, x
			bmi EndLoop

			tay
			sty ZP.Temp4

			lda #255
			sta ScoreQueue, x

			dec ScoresToProcess

			jsr AddScore

			ldy ZP.Temp4
			ldx ZP.X

			lda ShowPopup, y
			bmi EndLoop

			jsr POPUP.Show


		EndLoop:

			ldx ZP.X
			inx
			cpx #16
			bcc Loop


		Finish:




		rts
	}



	AddScore: {

		// y = scoreType
		// x = score index


		lda #0
		sta ZP.Amount

		ldx #0

		sed

		FirstDigit:

			lda ScoreL, y
			beq SecondDigit
			clc
			adc Value, x
			sta Value, x

			lda Value + 1, x
			adc #0
			sta Value + 1, x

			lda ZP.Amount
			adc #0
			sta ZP.Amount

		SecondDigit:
		
			lda ScoreM, y
			beq ThirdDigit
			clc
			adc Value + 1, x
			sta Value + 1, x

			lda ZP.Amount
			adc #0
			sta ZP.Amount

		ThirdDigit:

			lda ScoreH, y
			beq Finish
			clc
			adc ZP.Amount
			sta ZP.Amount

			
		Finish:

			lda Value + 2, x
			clc
			adc ZP.Amount
			sta Value + 2, x

			lda Value + 3, x
			adc #0
			sta Value + 3, x

			cld

		NowDraw:

			ldx #0
			jsr DrawP1
			jsr CheckHighScore
			jsr CheckExtraLife


		NoHigh:


		rts
	}	


	CheckExtraLife: {


		lda ZP.Amount
		beq NoTenThousandsChange

		cmp #1
		beq CheckEven

	CheckOdd:

		lda Value + 2
		and #%00000001
		beq NoTenThousandsChange


	CheckEven:

		lda Value + 2
		and #%00000001
		bne NoTenThousandsChange


		jmp PETER.IncreaseLives

	NoTenThousandsChange:




		rts
	}


	CheckHighScore: {

		lda Value + 3
		cmp Best + 3
		bcc NoHigh

		beq Check2

		jmp IsHigh


	Check2:

		lda Value + 2
		cmp Best + 2
		bcc NoHigh

		beq Check3

		jmp IsHigh

	Check3:

		lda Value + 1
		cmp Best + 1
		bcc NoHigh

		beq Check4

		jmp IsHigh

	Check4:

		lda Value
		cmp Best
		bcc NoHigh

	IsHigh:

		lda Value
		sta Best

		lda Value + 1
		sta Best + 1

		lda Value + 2
		sta Best + 2

		lda Value + 3
		sta Best + 3


		jsr DrawBest


		NoHigh:

		rts
	}



	
	DrawP1:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Value + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 1, x
		bne ScoreLoop

		dec ZP.EndID



		ScoreLoop:

			lda Value,x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble

			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop

		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 229, y

			lda #WHITE
			sta VIC.COLOR_RAM + 229, y
			dey
			rts


		}

		Finish:

		rts


	}

DrawBest:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Best+ 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Best + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Best + 1, x
		bne ScoreLoop

		dec ZP.EndID



		ScoreLoop:

			lda Best,x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble

			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop

		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 429, y

			lda #WHITE
			sta VIC.COLOR_RAM + 429, y
			dey
			rts


		}

		Finish:

		rts


	}
	



}