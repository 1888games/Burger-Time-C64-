.namespace TEXT {

	.label CharacterSetStart = 0
	.label Space = 0
	.label LineBreak = 47
	.label SpaceAscii = 32
	.label MonthStart = 0
	.label NUM_START = 48

	System_Text:

	

	Word:	.byte 0, 0
	PrDec16Tens: .word 1, 10, 100, 1000, 10000, 100000

	Pad:	.byte 0
	Digit:	.byte 0
	Digits:	.fill 6, 0
	DigitStart:	.byte 0
	DigitsToDraw: .byte 3
	NumStart:	.byte 26


	DrawByte: {

		sta Digits

		jsr PLOT.GetCharacter

		lda Digits
		jsr ByteToDigits

		jmp DrawDigits


	}



	DrawWord: {

		jsr PLOT.GetCharacter

		jmp DrawDigits


	}


	DrawDigits: {

		ldy DigitStart

	SkipLoop:

		lda Digits, y
		bne Loop

		lda #0
		sta (ZP.ScreenAddress), y

		iny
		cpy DigitsToDraw
		bne SkipLoop

		dey
		Loop:

			lda Digits, y

		ForceZero:
			clc
			adc NumStart
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny			
			cpy DigitsToDraw
			bcc Loop

		Quit:

		rts
	}

	ByteToDigits: {


		ldx #$FF
		sec

		Dec100:

			inx
			sbc #100
			bcs Dec100

		adc #100
		stx Digits + 0

		ldx #$FF
		sec

		Dec10:

			inx
			sbc #10
			bcs Dec10

		adc #10
		stx Digits + 1

		sta Digits + 2

		rts	

	}


	
	WordToDigits: {

		lda #0
		sta Pad
		sta Digit

		ldy #10

		Loop1:

			ldx #$FF
			sec

		Loop2:

			lda Word + 0
			sbc PrDec16Tens +0, y
			sta Word + 0

			lda Word + 1
			sbc PrDec16Tens + 1, y
			sta Word + 1

			inx
			bcs Loop2

			lda Word + 0
			adc PrDec16Tens +0, y
			sta Word + 0

			lda Word + 1
			adc PrDec16Tens + 1, y
			sta Word + 1

			txa

			Print:

				ldx Digit
				inc Digit
				sta Digits, x

			Next:

				dey
				dey
				bpl Loop1


		rts
	}

}
