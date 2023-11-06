UTILITY: {

	* = * "Utility"

	BankOutKernalAndBasic:{

		lda PROCESSOR_PORT
		and #%11111000
		ora #%00000101
		sta PROCESSOR_PORT
		rts
	}
		

	BankInKernal: {

		lda PROCESSOR_PORT
		and #%11111000
		ora #%00000110
		sta PROCESSOR_PORT
		rts

	}

	ClearScreen: {

		ldx #250
		lda #0

		Loop:

			sta SCREEN_RAM - 1, x
			sta SCREEN_RAM + 249, x
			sta SCREEN_RAM + 499, x
			sta SCREEN_RAM + 749, x

			dex
			bne Loop


		rts	


	}


	MoveDownRow: {


		lda ZP.ScreenAddress
		clc
		adc #40
		sta ZP.ScreenAddress

		lda ZP.ScreenAddress + 1
		adc #0
		sta ZP.ScreenAddress + 1


		lda ZP.ColourAddress
		clc
		adc #40
		sta ZP.ColourAddress

		lda ZP.ColourAddress + 1
		adc #0
		sta ZP.ColourAddress + 1

		rts

	}

	DrawText: {	

		sta ZP.Colour

		jsr PLOT.GetCharacter


		ldy #0

		Loop:

			lda (ZP.SourceAddress), y
			beq Done
			sta (ZP.ScreenAddress), y
		

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			jmp Loop

		Done:

			rts

	}

}