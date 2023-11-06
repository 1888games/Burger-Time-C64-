.namespace READY {

	
	RowStart:		.byte 11
	CharNum:		.byte 40
	RowColour:		.byte WHITE


	Timer:			.byte 0

	Show: {

	
		cli

		TurnOffScreen()
		
		lda #0
		sta VIC.SPRITE_MSB
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR
		sta VIC.BORDER_COLOR

		jsr SwitchCharset

		lda #9
		jsr MAPLOADER.DrawMap

		jsr ColourRows
	

		TurnOnScreen()



		lda #60
		sta Timer


		jmp Loop
	}


	ColourRows: {


		ldx #0

		RowLoop:

			stx ZP.X

			lda RowColour, x
			sta ZP.Colour

			lda CharNum, x
			sta ZP.Amount

			lda RowStart, x
			tay

			ldx #0

			jsr PLOT.GetCharacter

			ldy #0

		CharLoop:


			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			cpy ZP.Amount
			bcc CharLoop

			ldx ZP.X
			inx
			cpx #1
			bcc RowLoop


		rts
	}


	Loop: {


		jsr MAIN.WaitForIRQ

		lda Timer
		beq Ready

		dec Timer
		jmp Loop

	Ready:

		lda GAME.Started
		beq NewGame

		jmp GAME.Restart


	NewGame:

		jmp GAME.Start


	}

	SwitchCharset: {

		lda #%00001010
		sta VIC.MEMORY_SETUP

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		sta VIC.SCREEN_CONTROL_2

	
		rts
	}

}