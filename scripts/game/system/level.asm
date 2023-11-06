.namespace LEVEL {


	Tens:	.byte 0
	Fives:	.byte 0
	Digits:	.byte 0


	.label TEN_CHAR = 23
	.label FIVE_CHAR = 42
	.label BURGER_CHAR = 251


	Draw: {


		jsr CalcValues

		ldy #19
		ldx #37

		jsr PLOT.GetCharacter

		TensLoop:

			lda Tens
			beq FivesLoop

			ldy #0

			lda #TEN_CHAR
			sta (ZP.ScreenAddress), y

			lda #WHITE
			sta (ZP.ColourAddress), y

			jsr DrawBurger
			jsr GoUpRow
		
			dec Tens
			jmp TensLoop


		FivesLoop:


			lda Fives
			beq DigitLoop

			ldy #0

			lda #FIVE_CHAR
			sta (ZP.ScreenAddress), y

			lda #WHITE
			sta (ZP.ColourAddress), y

			jsr DrawBurger
			jsr GoUpRow
		
			dec Fives
			jmp FivesLoop

		DigitLoop:


			lda Digits
			beq Done

			ldy #0

		
			jsr DrawBurger
			jsr GoUpRow
		
			dec Digits
			jmp DigitLoop

		Done:

		rts
	}


	DrawBurger: {

		iny

		lda #BURGER_CHAR
		sta (ZP.ScreenAddress), y
		
		lda #GREEN + 8
		sta (ZP.ColourAddress), y

		rts

	}

	GoUpRow: {


		lda ZP.ScreenAddress
		sec
		sbc #40
		sta ZP.ScreenAddress

		lda ZP.ScreenAddress + 1
		sbc #0
		sta ZP.ScreenAddress + 1

		lda ZP.ColourAddress
		sec
		sbc #40
		sta ZP.ColourAddress

		lda ZP.ColourAddress + 1
		sbc #0
		sta ZP.ColourAddress + 1

		rts

	}


	CalcValues: {

		lda #0
		sta Tens
		sta Fives
		sta Digits

		lda GAME.CurrentLevel
		clc
		adc #1

	CalcTens:

		sec
		sbc #10
		bmi OutOfTens

		inc Tens

		jmp CalcTens


	OutOfTens:

		clc
		adc #10

	CalcFives:

		sec
		sbc #5
		bmi OutOfFives

		inc Fives

		jmp CalcFives

	OutOfFives:

		clc
		adc #5
		sta Digits


		rts

	}



}